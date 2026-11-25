# frozen_string_literal: true

# How apps on view_component-contrib name sidecar previews: Badge::Preview → "badge".
ViewComponent::Preview.extend ViewComponentContrib::Preview::Sidecarable
ViewComponent::Preview.extend ViewComponentContrib::Preview::Abstract
