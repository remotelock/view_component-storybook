# frozen_string_literal: true

module ViewComponent
  module Storybook
    # One example of a preview, as a Storybook story rendered by the ViewComponent preview route.
    class Story
      attr_reader :preview, :method_object

      def initialize(preview, method_object)
        @preview = preview
        @method_object = method_object
      end

      def name
        method_object.name.to_sym
      end

      # The ViewComponent preview route's path for this example, and Storybook's `parameters.server.id`.
      def id
        "#{preview.preview_name}/#{name}"
      end

      def label
        method_object.tag(:label)&.text.presence || name.to_s.titleize
      end

      def source
        return @source if defined?(@source)

        @source = Source.for(preview.preview_class, name, method_object)
      end

      # The DSL's controls, else one inferred from the component's dry-types option or the default value,
      # for every keyword the example takes.
      def controls
        @controls ||= begin
          declared = Array(preview.preview_class.try(:storybook_controls, name, preview.code_object))
          inferred = keyword_params.filter_map do |param, default_source|
            infer_control(param, default_source) if declared.none? { |control| control.param == param }
          end
          by_param = (declared + inferred).index_by(&:param)
          keyword_params.filter_map { |param, _| by_param.delete(param) } + by_param.values
        end
      end

      # Params as Storybook sends them (strings), coerced to the values the example expects.
      def coerce(params)
        values = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
        values = values.to_h.symbolize_keys
        controls.each do |control|
          values[control.param] = control.parse_param_value(values[control.param]) if values.key?(control.param)
        end
        values
      end

      def to_csf_params
        csf_params = { name: label, parameters: { server: { id: id } } }
        csf_params[:parameters][:docs] = { source: source } if source
        parameters = preview.preview_class.try(:storybook_story_parameters, name)
        csf_params.deep_merge!(parameters: parameters) if parameters.present?
        controls.each { |control| csf_params.deep_merge!(control.to_csf_params) }
        csf_params
      end

      private

      def keyword_params
        @keyword_params ||= method_object.parameters.filter_map do |param, default_source|
          [param.chomp(":").to_sym, default_source] if param.end_with?(":")
        end
      end

      def infer_control(param, default_source)
        definition = preview.definitions[param]
        Inference.control(
          param,
          type: definition&.type,
          default: evaluate(default_source),
          description: definition&.desc
        )
      end

      def evaluate(default_source)
        Storybook.evaluate_default(default_source, preview.preview_class.new)
      end
    end
  end
end
