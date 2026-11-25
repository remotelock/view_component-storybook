# frozen_string_literal: true

module ViewComponent
  module Storybook
    # Finds the component a preview renders and turns its dry-types options into Storybook controls.
    module Inference
      module_function

      # A `@component` tag on the preview, else view_component-contrib's `component_class_name`, else
      # `Foo::Preview` / `FooPreview` / `FooStories` → `Foo::Component`, `FooComponent`, then `Foo`.
      def component_class(preview_class, code_object = nil)
        tagged = code_object&.tag(:component)&.text.presence
        return component(tagged.safe_constantize) if tagged

        if preview_class.respond_to?(:component_class_name)
          named = component(preview_class.component_class_name.to_s.safe_constantize)
          return named if named
        end

        base = preview_class.name.sub(/(::Preview|Preview|Stories)\z/, "")
        ["#{base}::Component", "#{base}Component", base].lazy.filter_map { |name| component(name.safe_constantize) }.first
      end

      def component(candidate)
        candidate if candidate.is_a?(Class) && candidate <= ViewComponent::Base
      end

      def definitions(component_class)
        return {} unless component_class.respond_to?(:dry_initializer)

        component_class.dry_initializer.definitions.transform_keys(&:to_sym)
      end

      # A control for a param: from its dry type when it says enough, else from the default value.
      def control(param, type:, default:, description: nil)
        options = { default: default, description: description }

        if (enum = enum_type(type))
          return Controls::Options.new(param, type: :select, options: enum.values, **options)
        end

        from_type(param, primitives(type) - [NilClass], options) || from_default(param, default, options)
      end

      # Which control a set of Ruby classes gets, first match wins.
      TYPE_CONTROLS = [
        [->(primitive) { [TrueClass, FalseClass].include?(primitive) },
         ->(param, _, opts) { Controls::Boolean.new(param, **opts) }],
        [->(primitive) { primitive <= Numeric }, ->(param, _, opts) { Controls::Number.new(param, type: :number, **opts) }],
        [->(primitive) { primitive <= ::Date || primitive <= ::Time },
         ->(param, primitives, opts) { Controls::Date.new(param, ruby_class: primitives.first, **opts) }],
        [->(primitive) { primitive <= ::String || primitive <= ::Symbol },
         ->(param, primitives, opts) { Controls::Text.new(param, symbol: primitives.include?(::Symbol), **opts) }],
        [->(primitive) { primitive <= ::Hash || primitive <= ::Array },
         ->(param, _, opts) { Controls::Object.new(param, **opts) }]
      ].freeze

      def from_type(param, primitives, options)
        return if primitives.empty?

        _, build = TYPE_CONTROLS.find { |test, _| primitives.all?(&test) }
        build&.call(param, primitives, options)
      end

      def from_default(param, default, options)
        case default
        when true, false then Controls::Boolean.new(param, **options)
        when Numeric then Controls::Number.new(param, type: :number, **options)
        when ::Date, ::Time then Controls::Date.new(param, **options)
        when ::Hash, ::Array then Controls::Object.new(param, **options)
        when ::String, ::Symbol, nil then Controls::Text.new(param, **options)
        end
      end

      def enum_type(type)
        return unless defined?(Dry::Types)

        case type
        when Dry::Types::Enum then type
        when Dry::Types::Sum then enum_type(type.left) || enum_type(type.right)
        else enum_type(type.type) if decorator?(type)
        end
      end

      # The Ruby classes a dry type admits: `Types::String.optional` → [NilClass, String].
      def primitives(type)
        return [] unless defined?(Dry::Types) && type.is_a?(Dry::Types::Type)

        case type
        when Dry::Types::Sum then primitives(type.left) | primitives(type.right)
        else
          if type.respond_to?(:primitive)
            [type.primitive]
          elsif decorator?(type)
            primitives(type.type)
          else
            []
          end
        end
      end

      def decorator?(type)
        defined?(Dry::Types) && type.is_a?(Dry::Types::Type) && type.respond_to?(:type) && !type.type.equal?(type)
      end
    end
  end
end
