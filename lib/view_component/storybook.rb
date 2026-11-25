# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_model"
require "view_component"
require "yard"
require "zeitwerk"

module ViewComponent
  module Storybook
    loader = Zeitwerk::Loader.for_gem_extension(ViewComponent)
    loader.ignore("#{__dir__}/storybook/tasks")
    loader.setup

    # Where `write_stories_json` writes the `*.stories.json` files. `nil` (the default) writes each one
    # next to its preview; a directory writes them all there, one per preview, nested by preview name:
    #
    #     config.view_component_storybook.stories_json_path = Rails.root.join("storybook/stories")
    #
    mattr_accessor :stories_json_path, instance_writer: false

    # Where `write_static_html` writes each story's HTML when the task isn't given a directory.
    # Defaults to `tmp/storybook/html` under the application's root.
    mattr_accessor :static_html_path, instance_writer: false

    # Directories of deprecated `ViewComponent::Storybook::Stories` classes. `test/components/stories`
    # is added when it exists. They're added to ViewComponent's preview paths.
    mattr_accessor :stories_paths, instance_writer: false, default: []

    # How a preview's Storybook title is generated when it has no `@title` tag:
    #
    #     config.view_component_storybook.stories_title_generator = lambda { |preview|
    #       preview.preview_name.humanize.upcase
    #     }
    #
    mattr_accessor :stories_title_generator, instance_writer: false,
                                             default: ->(preview) { preview.preview_name.humanize.titlecase }

    YARD::Tags::Library.define_tag("Storybook title", :title)
    YARD::Tags::Library.define_tag("Component the preview renders", :component)
    YARD::Tags::Library.define_tag("Story name", :label)

    class << self
      # Every preview Storybook can show, in a collection that reads them once and is reset on reload.
      def previews
        @previews ||= Collections::PreviewsCollection.load
      end

      def reset!
        @previews = nil
      end

      # A keyword's default as YARD records it (`%w[a b],` on a multi-line signature), evaluated in
      # `context`. `nil` when it can't be evaluated outside the example.
      def evaluate_default(source, context)
        return if source.nil?

        context.instance_eval(source.strip.delete_suffix(","))
      rescue StandardError, ScriptError
        nil
      end

      def deprecator
        @deprecator ||= ActiveSupport::Deprecation.new("3.0", "ViewComponent::Storybook")
      end
    end

    ActiveSupport.run_load_hooks(:view_component_storybook, self)
  end
end

ViewComponent::Storybook::Engine if defined?(Rails::Engine)
