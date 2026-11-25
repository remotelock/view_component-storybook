---
layout: default
title: Changelog
---

# Changelog

## main

## 2.0.0

RemoteLock's fork, for ViewComponent 4 and Storybook 10.

* Requires Ruby 3.3+, Rails 7.1+ and ViewComponent 4; works with Storybook 10's `@storybook/server-webpack5`.
* Reads plain `ViewComponent::Preview` classes from ViewComponent's preview paths. A `@title` tag sets the title, `@label` a story's name, and `@component` the component when the preview's name doesn't lead to it. Stories keep their declaration order.
* `ViewComponent::Storybook::Stories` is deprecated. It still works and keeps its DSL.
* Each story carries its source in `parameters.docs.source`: the example's own template when it has one, else its method body. Templates resolve through the preview's `preview_example_template_path`, so view_component-contrib's sidecar layout works.
* Controls are inferred for every keyword, from the component's dry-initializer/dry-types option (enum → select, Bool → boolean, Integer/Float → number, String/Symbol → text, Date/Time → date, Hash/Array → object) or else the default value. `control` overrides.
* Args Storybook sends back are coerced through their control before the example runs, for previews and stories alike.
* `stories_json_path` writes every `*.stories.json` into one directory, nested by preview name.
* New `view_component_storybook:write_static_html[dir]` renders every story through the preview route and writes `<dir>/<story id>.html`, for a Storybook hosted without Rails.
* Story names are titleized (`"Short Button"`); Storybook's ids don't change.
* Removed: `show_stories` and `stories_route` (ViewComponent's `previews.enabled` and `previews.route` decide), the manual `require "view_component/storybook/engine"` shim, and `ActiveSupport::Configurable`. The gem loads with Zeitwerk.

## 0.12.1

Last 0.x release
* Prepare for renaming to `view_component-storybook` to align with Rubygems naming conventions and simpler installation.

## 0.12.0

* Allow configuration of story titles via new `stories_title_generator` configuration lambda
* Added control descriptions
* Fixed bug with autoload paths
* Fixed Documentation typos

## 0.11.1

* Fix for stories_route by when using deprecated `require "view_component/storybook/engine"`

## 0.11.0

* Add support for dry-initializer
* Validate Slots

## 0.10.1

* Allow Object Controls with arrays of simple values

## 0.10.0

* New Stories API
  * `title` - custom stories title 
  * `constructor` - component args
  * `slot` - args and content for slots
  * component and slot content accepts controls
* New Controls
  * Custom Control
  * Klazz Control
* Deprecated Controls DSL
* Add support for Object Controls with array values
* Remove ArrayConfig - array aliases Object
* Updated Options Control to match Storybook 6.2 syntax
  * `options` as array
  * add `labels` option
  * deprecate `options` as Hash
  * multi select types accept and return array values
* Improved validation errors with i18n support
* Add `stories_route` config to configure stories endpoint
* Jekyll docs

## 0.9.0

* Allow view helpers in content blocks

## 0.8.0

* Add support for components with keyword argument constructors

## 0.7.0

* Add inclusion validation to Number type
* Support Objects with nested values
* Support nil control values