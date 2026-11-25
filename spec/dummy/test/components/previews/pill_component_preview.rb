# frozen_string_literal: true

# @title Data/Pill
class PillComponentPreview < ViewComponent::Preview
  def default(label: "New", tone: :neutral, count: 0, dismissible: false)
    render PillComponent.new(label: label, tone: tone, count: count, dismissible: dismissible)
  end

  # @label Every tone
  def tones; end

  def with_size(label: "Small", size: "sm", since: Date.new(2026, 1, 2), data: { id: 1 })
    render PillComponent.new(label: label, size: size, since: since, data: data)
  end
end
