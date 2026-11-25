# ViewComponent::Storybook

Shows [ViewComponent](https://viewcomponent.org) previews in [Storybook](https://storybook.js.org) through
its [server renderer](https://github.com/storybookjs/storybook/tree/next/code/renderers/server). The gem
reads your previews and writes one CSF `*.stories.json` per preview. Storybook renders each story by
fetching it from your app's preview route, so controls re-render it live. For hosting without Rails, the
gem also pre-renders every story to static HTML.

This is RemoteLock's fork of [jonspalmer/view_component-storybook](https://github.com/jonspalmer/view_component-storybook),
brought up to date for ViewComponent 4 and Storybook 10.

## Requirements

- Ruby 3.3+, Rails 7.1+, ViewComponent 4
- Storybook 10 with `@storybook/server-webpack5`
- [dry-initializer](https://dry-rb.org/gems/dry-initializer) and [dry-types](https://dry-rb.org/gems/dry-types),
  optional, for inferred controls

## Install

```ruby
# Gemfile
group :development, :test do
  gem "view_component-storybook", github: "remotelock/view_component-storybook"
end
```

```sh
npm install --save-dev storybook@^10 @storybook/server-webpack5@^10
```

## Previews are the stories

Write ordinary ViewComponent previews. Every public example is a story, in the order it's declared:

```ruby
# test/components/previews/badge_component_preview.rb

# @title Data/Badge
class BadgeComponentPreview < ViewComponent::Preview
  def default(label: "New", tone: :neutral, count: 0, dismissible: false)
    render BadgeComponent.new(label:, tone:, count:, dismissible:)
  end

  # @label Every tone
  def tones; end # renders badge_component_preview/tones.html.erb
end
```

| Story field | Comes from |
| --- | --- |
| title | the class's `@title` tag, else `stories_title_generator` (`"Badge Component"`) |
| name | the example's `@label` tag, else its titleized name (`"Default"`) |
| `parameters.server.id` | the preview route's path, `<preview_name>/<example>` |
| `parameters.docs.source` | the example's own template when it has one (`language: "erb"`), else its method body (`"ruby"`) |
| `args` | the example's keyword defaults |
| `argTypes` | a control per keyword, see below |

The template lookup goes through the preview's own `preview_example_template_path`. That makes it work
with [view_component-contrib](https://github.com/palkan/view_component-contrib)'s sidecar layout
(`button/preview.rb`, `button/previews/<example>.html.erb`) as well as ViewComponent's. Abstract previews
(`abstract_class = true`, like `ViewComponentContrib::Preview::Base`) are skipped.

## Controls are inferred

Each keyword an example takes gets a control.

1. **The component's dry-types option.** The component is the preview's `@component` tag, else
   view_component-contrib's `component_class_name`, else the preview's name: `Foo::Preview` →
   `Foo::Component`, `FooComponentPreview` → `FooComponent`, `FooPreview` → `Foo`. Its dry-initializer
   option (or param) with the keyword's name decides the control:

   | dry type | control |
   | --- | --- |
   | `.enum(...)`, through `.optional`/`.default` | `select` of its values |
   | `Bool` | `boolean` |
   | `Integer`, `Float`, `Decimal` | `number` |
   | `String`, `Symbol` | `text` |
   | `Date`, `DateTime`, `Time` | `date` |
   | `Hash`, `Array` | `object` |

   The option's `desc:` becomes the control's description.
2. **Else the default value**: `true`/`false`, a number, a date, a hash or array, a string or symbol. A
   default that can't be sent to Storybook (a model, say) gets no control.

Storybook sends every arg back as a string, so the gem coerces each one through its control before the
example runs. `"danger"` arrives as `:danger` for a symbol enum, `"true"` as `true`, `"3"` as `3`, an ISO
date as a `Date` for a `Date` option, and JSON as a hash.

## Storybook setup

```js
// .storybook/main.js
export default {
  stories: ["../storybook/stories/**/*.stories.json"],
  framework: { name: "@storybook/server-webpack5", options: {} },
  // Only used by a static build, see below.
  staticDirs: [{ from: "../tmp/storybook/html", to: "/stories-html" }],
};
```

```js
// .storybook/preview.js
// A static build (STORYBOOK_STATIC_HTML set) reads the HTML write_static_html wrote;
// otherwise Storybook asks the running Rails app, so controls re-render the story.
const staticHtml = process.env.STORYBOOK_STATIC_HTML;

export default {
  parameters: {
    server: staticHtml
      ? {
          url: staticHtml,
          fetchStoryHtml: async (url, id) => {
            const response = await fetch(`${url}/${id}.html`);
            if (!response.ok) throw new Error(`${response.status}: ${url}/${id}.html`);
            return response.text();
          },
        }
      : { url: "http://localhost:3000/rails/view_components" },
  },
};
```

Storybook runs on another port, so in development the app must allow it to fetch previews, for
example with [rack-cors](https://github.com/cyu/rack-cors) allowing `GET` from `http://localhost:6006`.
Storybook puts the response into its canvas, so give previews a layout that loads your stylesheet and
JavaScript (`config.view_component.previews.default_layout`).

```ruby
# config/environments/development.rb
config.view_component_storybook.stories_json_path = Rails.root.join("storybook/stories")
```

```sh
bin/rails view_component_storybook:write_stories_json
bin/rails server & npx storybook dev -p 6006
```

## Static build

`write_static_html` renders every story at its default args through the app's real preview route, and
writes exactly what the route returns to `<dir>/<story id>.html`. A Storybook built with those files
needs no Rails behind it, so it can be hosted on any static host. Static stories render their defaults,
and controls only re-render against a live server.

```sh
bin/rails view_component_storybook:write_stories_json
bin/rails "view_component_storybook:write_static_html[tmp/storybook/html]"
STORYBOOK_STATIC_HTML=./stories-html npx storybook build -o storybook-static
```

Run the tasks in an environment where previews are enabled: `development`, or one that sets
`config.view_component.previews.enabled`.

## Configuration

```ruby
# config/application.rb or an environment file
config.view_component_storybook.stories_json_path = Rails.root.join("storybook/stories") # default: next to each preview
config.view_component_storybook.static_html_path = Rails.root.join("tmp/storybook/html") # the default
config.view_component_storybook.stories_title_generator = ->(preview) { preview.preview_name.titleize }
```

ViewComponent's own preview settings apply: `config.view_component.previews.paths`, `.route` and
`.default_layout`.

## Rake tasks

| Task | Does |
| --- | --- |
| `view_component_storybook:write_stories_json` | Writes a `*.stories.json` per preview |
| `view_component_storybook:remove_stories_json` | Removes them |
| `view_component_storybook:write_static_html[dir]` | Writes `<dir>/<story id>.html` for every story (default `static_html_path`), and fails listing any story that didn't render |

## The JSON

```json
{
  "title": "Data/Badge",
  "stories": [
    {
      "name": "Default",
      "parameters": {
        "server": { "id": "badge_component/default" },
        "docs": { "source": { "code": "render BadgeComponent.new(label:, tone:, count:, dismissible:)", "language": "ruby" } }
      },
      "args": { "label": "New", "tone": "neutral", "count": 0, "dismissible": false },
      "argTypes": {
        "tone": { "control": { "type": "select" }, "name": "Tone", "options": ["neutral", "success", "danger"] }
      }
    }
  ]
}
```

## Migrating from 1.x

- Requires Ruby 3.3, Rails 7.1, ViewComponent 4 and Storybook 10 (`@storybook/server-webpack5`).
- Write `ViewComponent::Preview` classes. `ViewComponent::Storybook::Stories` still works and keeps its
  `control`, `parameters`, `layout` and `title` DSL, but it's deprecated. Its files in
  `test/components/stories` (or `stories_paths`) are still loaded.
- `title "..."` becomes a `@title` tag. `control` is only needed to override an inferred control.
- Story names are titleized (`"Short Button"`, was `"short_button"`). Storybook's story ids don't change.
- Every keyword gets a control, not just the ones with a `control` declaration.
- `show_stories` and `stories_route` are gone: ViewComponent's `previews.enabled` and `previews.route`
  decide. `stories_json_path` writes all the JSON into one directory.

## License

MIT, see [LICENSE.txt](LICENSE.txt). Originally by Jon Palmer.
