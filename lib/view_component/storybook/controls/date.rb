# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Controls
      class Date < SimpleControl
        # `ruby_class` is what the example expects back: a ::Date, a ::DateTime or a ::Time.
        def initialize(param, ruby_class: nil, **)
          super(param, **)
          @ruby_class = ruby_class || default&.class
        end

        def type
          :date
        end

        def parse_param_value(value)
          return value unless value.is_a?(String)

          parsed = DateTime.iso8601(value)
          if @ruby_class.is_a?(Class) && @ruby_class <= ::Time
            parsed.to_time
          elsif @ruby_class == ::Date
            parsed.to_date
          else
            parsed
          end
        end

        private

        def csf_value
          case default
          when ::Date
            default.in_time_zone.iso8601
          when Time
            default.iso8601
          end
        end
      end
    end
  end
end
