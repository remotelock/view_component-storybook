# frozen_string_literal: true

module TagChip
  class Component < ViewComponent::Base
    extend Dry::Initializer

    option :variant, Types::Symbol.enum(:solid, :outlined), default: proc { :solid }
    option :label, Types::String, default: proc { "Tag" }

    def call
      content_tag(:span, label, class: "tag-chip tag-chip--#{variant}")
    end
  end
end
