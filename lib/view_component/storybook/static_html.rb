# frozen_string_literal: true

module ViewComponent
  module Storybook
    # Renders every story at its default args through the app's own preview route and writes the HTML
    # the route returns to `<dir>/<story id>.html`, so a built Storybook can be hosted without Rails.
    module StaticHtml
      class RenderError < StandardError; end

      module_function

      def write(dir = Storybook.static_html_path)
        request = Rack::MockRequest.new(Rails.application)
        errors = []

        written = Storybook.previews.flat_map(&:stories).filter_map do |story|
          response = request.get(route(story), env)
          raise RenderError, "HTTP #{response.status}" unless response.status == 200

          path = File.join(dir.to_s, "#{story.id}.html")
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, response.body)
          path
        rescue StandardError => e
          errors << "#{story.id}: #{e.message}"
          nil
        end

        raise RenderError, "Couldn't render #{errors.size} stories:\n#{errors.join("\n")}" if errors.any?

        written
      end

      def route(story)
        "#{ViewComponent::Base.config.previews.route}/#{story.id}"
      end

      def env
        {
          "HTTP_HOST" => "localhost",
          "REMOTE_ADDR" => "127.0.0.1",
          "HTTPS" => Rails.application.config.force_ssl ? "on" : "off"
        }
      end
    end
  end
end
