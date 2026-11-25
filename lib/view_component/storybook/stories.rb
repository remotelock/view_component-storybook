# frozen_string_literal: true

module ViewComponent
  module Storybook
    # Deprecated: write a plain `ViewComponent::Preview`. Its controls are inferred from the component's
    # dry-types options and the examples' keyword defaults, and `@title` sets its title.
    class Stories < ViewComponent::Preview
      class << self
        def inherited(child)
          super
          Storybook.deprecator.warn(
            "#{child.name || 'A'} subclasses ViewComponent::Storybook::Stories, which is deprecated. " \
            "Write a ViewComponent::Preview instead: view_component-storybook 2 reads previews."
          )
        end

        def title(title = nil)
          @stories_title = title
        end

        def parameters(params, only: nil, except: nil)
          parameters_collection.add(params, only: only, except: except)
        end

        def layout(layout, only: nil, except: nil)
          layout_collection.add(layout, only: only, except: except)
        end

        def control(param, as:, **)
          controls.add(param, as: as, **)
        end

        def stories_name
          name.chomp("Stories").underscore
        end

        def preview_name
          stories_name
        end

        def stories_title_override
          @stories_title
        end

        def storybook_parameters
          parameters_collection.for_all
        end

        def storybook_story_parameters(story_name)
          parameters_collection.for_story(story_name)
        end

        def storybook_controls(story_name, code_object)
          return [] unless code_object

          controls.code_object = code_object
          controls.for_story(story_name)
        end

        def render_args(story_name, params: {})
          @layout = layout_collection.for_story(story_name.to_sym)
          super
        end

        delegate :to_csf_params, to: :storybook

        delegate :write_csf_json, to: :storybook

        delegate :stories, to: :storybook

        delegate :find_story, to: :storybook

        delegate :code_object, to: :storybook

        def stories_json_path
          storybook.json_path
        end

        private

        def storybook
          Storybook.previews.find(self) || PreviewStories.new(self, nil)
        end

        def controls
          @controls ||= Collections::ControlsCollection.new
        end

        def parameters_collection
          @parameters_collection ||= Collections::ParametersCollection.new
        end

        def layout_collection
          @layout_collection ||= Collections::LayoutCollection.new
        end
      end
    end
  end
end
