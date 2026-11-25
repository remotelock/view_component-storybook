# frozen_string_literal: true

module ViewComponent
  module Storybook
    class Engine < Rails::Engine
      config.view_component_storybook = ActiveSupport::OrderedOptions.new
      config.view_component_storybook.stories_paths = []

      initializer "view_component_storybook.set_configs",
                  after: "view_component.set_configs", before: "view_component.set_autoload_paths" do |app|
        options = app.config.view_component_storybook

        stories_dir = Rails.root.join("test/components/stories").to_s
        options.stories_paths |= [stories_dir] if Dir.exist?(stories_dir)
        options.static_html_path ||= Rails.root.join("tmp/storybook/html").to_s

        # ViewComponent autoloads its preview paths, and its controller finds stories classes among them.
        previews = app.config.view_component.previews
        previews.paths |= options.stories_paths.map(&:to_s) if previews.enabled != false

        Engine.apply(options)
      end

      initializer "view_component_storybook.deprecator" do |app|
        app.deprecators[:view_component_storybook] = Storybook.deprecator if app.respond_to?(:deprecators)
      end

      # After the app's initializers: ViewComponent::Preview includes the app's url helpers when it loads.
      config.after_initialize do
        ViewComponent::Preview.singleton_class.prepend(PreviewExtension)
      end

      config.to_prepare { Storybook.reset! }

      REMOVED_OPTIONS = {
        show_stories: "ViewComponent's config.view_component.previews.enabled decides",
        stories_route: "stories render at ViewComponent's config.view_component.previews.route"
      }.freeze

      def self.apply(options)
        options.each do |key, value|
          if REMOVED_OPTIONS.key?(key.to_sym)
            Storybook.deprecator.warn("config.view_component_storybook.#{key} is ignored: #{REMOVED_OPTIONS[key.to_sym]}")
          else
            Storybook.public_send(:"#{key}=", value)
          end
        end
      end

      rake_tasks do
        load File.join(__dir__, "tasks/view_component_storybook.rake")
      end
    end
  end
end
