# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Controls
      class MultiOptions < BaseOptions
        TYPES = %i[multi-select check inline-check].freeze

        validates :type, inclusion: { in: TYPES }, unless: -> { type.nil? }
        validate :validate_default, unless: -> { options.nil? || default.nil? }

        def initialize(param, type:, options:, default: nil, labels: nil, name: nil, description: nil, **)
          super(param, type: type, options: options, default: Array.wrap(default), labels: labels, name: name,
                       description: description, **)
        end

        def parse_param_value(value)
          return value unless value.is_a?(String)

          value.split(",").map do |item|
            options.find { |option| option.to_s == item } || (symbol_values? ? item.to_sym : item)
          end
        end

        def to_csf_params
          super.deep_merge(argTypes: { param => { options: options } })
        end

        private

        def csf_control_params
          labels.nil? ? super : super.merge(labels: labels)
        end

        def symbol_values?
          options.first.is_a?(Symbol)
        end

        def validate_default
          errors.add(:default, :inclusion) unless default.to_set <= options.to_set
        end
      end
    end
  end
end
