# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Controls
      class Options < BaseOptions
        TYPES = %i[select radio inline-radio].freeze

        validates :type, inclusion: { in: TYPES }, unless: -> { type.nil? }
        validates :default, inclusion: { in: ->(config) { config.options } }, unless: -> { options.nil? || default.nil? }

        # Storybook sends the option as a string; give the example the option itself, whatever its type.
        def parse_param_value(value)
          return value unless value.is_a?(String)

          options.find { |option| option.to_s == value } || (symbol_values? ? value.to_sym : value)
        end

        def to_csf_params
          super.deep_merge(argTypes: { param => { options: options } })
        end

        private

        def csf_control_params
          labels.nil? ? super : super.merge(labels: labels)
        end

        def symbol_values?
          default.is_a?(Symbol) || Array(options).first.is_a?(Symbol)
        end
      end
    end
  end
end
