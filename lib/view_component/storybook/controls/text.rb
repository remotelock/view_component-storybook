# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Controls
      class Text < SimpleControl
        # A Symbol param round-trips as text: Storybook sends "primary", the example gets :primary.
        def initialize(param, symbol: nil, **)
          super(param, **)
          @symbol = symbol.nil? ? default.is_a?(Symbol) : symbol
        end

        def type
          :text
        end

        def parse_param_value(value)
          @symbol && value.is_a?(String) && value.present? ? value.to_sym : value
        end
      end
    end
  end
end
