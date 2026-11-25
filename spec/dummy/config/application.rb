# frozen_string_literal: true

require File.expand_path("boot", __dir__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

require "dry-initializer"
require "dry-types"
require "view_component"
require "view_component-contrib"
require "view_component/storybook"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.secret_key_base = "foo"
    config.root = File.expand_path("..", __dir__)

    # view_component-contrib's sidecar layout: app/components/<name>/{component,preview}.rb
    config.view_component.previews.paths << Rails.root.join("app/components").to_s
  end
end
