# frozen_string_literal: true

class PillComponent < ViewComponent::Base
  extend Dry::Initializer

  option :label, Types::String, desc: "The pill's words"
  option :tone, Types::Symbol.enum(:neutral, :success, :danger), default: proc { :neutral }
  option :size, Types::String.enum("sm", "md").optional, optional: true
  option :count, Types::Integer, default: proc { 0 }
  option :dismissible, Types::Bool, default: proc { false }
  option :since, Types::Date.optional, optional: true
  option :data, Types::Hash, default: proc { {} }

  def call
    classes = ["pill", "pill--#{tone}", size && "pill--#{size}", dismissible ? "pill--dismissible" : nil].compact
    content_tag(:span, "#{label} (#{count})#{" since #{since.iso8601}" if since}", class: classes.join(" "), data: data)
  end
end
