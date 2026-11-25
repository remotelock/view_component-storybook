# frozen_string_literal: true

require "prism"

module ViewComponent
  module Storybook
    # An example's source for Storybook Docs: its own template when it has one, else its method body.
    module Source
      module_function

      LANGUAGES = { ".erb" => "erb", ".haml" => "haml", ".slim" => "slim" }.freeze

      def for(preview_class, example, method_object)
        template(preview_class, example) || ruby(method_object)
      end

      # Resolved through the preview's own `preview_example_template_path`, so view_component-contrib's
      # sidecar layout (`<component>/previews/<example>.html.erb`) works as well as ViewComponent's.
      def template(preview_class, example)
        path = preview_class.preview_example_template_path(example.to_s).to_s
        return unless File.basename(path) == example.to_s

        file = ViewComponent::Base.config.previews.paths.lazy.filter_map { |dir| Dir["#{dir}/#{path}.html.*"].first }.first
        { code: File.read(file).strip, language: LANGUAGES.fetch(File.extname(file), "html") } if file
      rescue StandardError
        nil
      end

      def ruby(method_object)
        source = method_object&.source
        return if source.blank?

        definition = Prism.parse(source).value.statements.body.first
        body = definition.is_a?(Prism::DefNode) && definition.body
        return unless body

        code = (" " * body.location.start_column) + source.byteslice(body.location.start_offset...body.location.end_offset)
        { code: dedent(code), language: "ruby" }
      end

      def dedent(code)
        lines = code.lines
        indent = lines.reject { |line| line.strip.empty? }.map { |line| line[/\A */].size }.min || 0
        lines.map { |line| line.sub(/\A {0,#{indent}}/, "") }.join.strip
      end
    end
  end
end
