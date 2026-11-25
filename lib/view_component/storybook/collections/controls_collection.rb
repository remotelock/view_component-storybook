# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Collections
      class ControlsCollection
        include Collections::ValidForStoryConcern

        CONTROLS = {
          text: [Controls::Text, {}],
          boolean: [Controls::Boolean, {}],
          number: [Controls::Number, { type: :number }],
          range: [Controls::Number, { type: :range }],
          color: [Controls::Color, {}],
          object: [Controls::Object, {}],
          array: [Controls::Object, {}],
          select: [Controls::Options, { type: :select }],
          multi_select: [Controls::MultiOptions, { type: :"multi-select" }],
          radio: [Controls::Options, { type: :radio }],
          inline_radio: [Controls::Options, { type: :"inline-radio" }],
          check: [Controls::MultiOptions, { type: :check }],
          inline_check: [Controls::MultiOptions, { type: :"inline-check" }],
          date: [Controls::Date, {}]
        }.freeze

        attr_reader :controls

        attr_accessor :code_object

        def initialize
          @controls = []
        end

        def add(param, as:, only: nil, except: nil, **)
          controls << { param: param, as: as, only: only, except: except, ** }
        end

        def for_story(story_name)
          # build the controls for the story_name
          # pass through a hash to get the last valid control declared for each param
          controls.map do |opts|
            next unless valid_for_story?(story_name, **opts.slice(:only, :except))

            param = opts[:param]
            opts = opts.merge(default: parse_default(story_name, param)) unless opts.key?(:default)
            [param, build_control(param, **opts.except(:param, :only, :except))]
          end.compact.to_h.values
        end

        private

        def parse_default(story_name, param)
          code_method = code_object.meths.find { |m| m.name == story_name }
          default_value_parts = code_method.parameters.find { |parts| parts[0].chomp(":") == param.to_s }
          return unless default_value_parts

          Storybook.evaluate_default(default_value_parts[1], code_method)
        end

        def build_control(param, as:, **)
          klass, defaults = CONTROLS.fetch(as) { raise ArgumentError, "Unknown control type '#{as}'" }
          klass.new(param, **defaults, **)
        end
      end
    end
  end
end
