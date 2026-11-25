# frozen_string_literal: true

# A preview whose name doesn't lead to its component.
#
# @component PillComponent
class BadgePreview < ViewComponent::Preview
  def default(tone: :success)
    render PillComponent.new(label: "Badge", tone: tone)
  end
end
