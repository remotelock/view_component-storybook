# frozen_string_literal: true

module ViewComponent
  module Storybook
    # The stories of one ViewComponent preview: one per public example, in the order they're declared.
    class PreviewStories
      attr_reader :preview_class, :code_object

      delegate :preview_name, to: :preview_class

      def initialize(preview_class, code_object)
        @preview_class = preview_class
        @code_object = code_object
      end

      def title
        preview_class.try(:stories_title_override).presence ||
          code_object&.tag(:title)&.text.presence ||
          Storybook.stories_title_generator.call(preview_class)
      end

      def stories
        @stories ||= begin
          examples = preview_class.examples
          example_methods.select { |method| examples.include?(method.name.to_s) }.map { |method| Story.new(self, method) }
        end
      end

      def find_story(name)
        stories.find { |story| story.name == name.to_sym }
      end

      def component_class
        return @component_class if defined?(@component_class)

        @component_class = Inference.component_class(preview_class, code_object)
      end

      # The component's dry-initializer params and options, by name.
      def definitions
        @definitions ||= Inference.definitions(component_class)
      end

      def to_csf_params
        csf_params = { title: title }
        parameters = preview_class.try(:storybook_parameters)
        csf_params[:parameters] = parameters if parameters.present?
        csf_params[:stories] = stories.map(&:to_csf_params)
        csf_params
      end

      def json_path
        if Storybook.stories_json_path
          File.join(Storybook.stories_json_path.to_s, "#{preview_name}.stories.json")
        else
          File.join(File.dirname(code_object.file), "#{preview_class.name.demodulize.underscore}.stories.json")
        end
      end

      def write_csf_json
        path = json_path
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(to_csf_params))
        path
      end

      private

      def example_methods
        return [] unless code_object

        code_object.meths(inherited: false, included: false, scope: :instance, visibility: :public)
      end
    end
  end
end
