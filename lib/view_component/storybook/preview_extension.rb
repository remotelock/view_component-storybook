# frozen_string_literal: true

module ViewComponent
  module Storybook
    # Prepended to ViewComponent::Preview's class methods.
    module PreviewExtension
      # Load every preview file, and the deprecated Stories classes, before listing them: the preview
      # route looks examples up here, and view_component-contrib's `all` skips loading once any
      # preview is loaded.
      def all
        Collections::PreviewsCollection.load_stories_files
        __vc_load_previews if respond_to?(:__vc_load_previews, true)
        super
      end

      # Storybook sends every arg as a string. Coerce the ones a story has a control for before
      # ViewComponent passes them to the example, so "true" arrives as true and "primary" as :primary.
      def render_args(example, params: {})
        story = storybook_story(example)
        super(example, params: story ? story.coerce(params) : params)
      end

      private

      def storybook_story(example)
        Storybook.previews.find_story(self, example)
      rescue StandardError => e
        Rails.logger&.warn("[view_component-storybook] #{name}##{example}: #{e.message}")
        nil
      end
    end
  end
end
