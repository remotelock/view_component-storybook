# frozen_string_literal: true

module TagChip
  # A view_component-contrib sidecar preview.
  class Preview < ViewComponentContrib::Preview::Base
    def default(variant: :solid, label: "Tag")
      render_component(variant: variant, label: label)
    end

    def outlined; end

    def with_locals(label: "From locals")
      render_with(label: label)
    end
  end
end
