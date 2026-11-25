# frozen_string_literal: true

require_relative "lib/view_component/storybook/version"

Gem::Specification.new do |spec|
  spec.name          = "view_component-storybook"
  spec.version       = ViewComponent::Storybook::VERSION
  spec.authors       = ["Jon Palmer", "RemoteLock"]
  spec.email         = ["328224+jonspalmer@users.noreply.github.com"]

  spec.summary       = "Storybook for Rails ViewComponents"
  spec.description   = "Writes Storybook CSF JSON for ViewComponent previews, " \
                       "renders them for Storybook's server renderer, and pre-renders them for a static Storybook"

  spec.homepage      = "https://github.com/remotelock/view_component-storybook"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/docs/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["docs/CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "railties", ">= 7.1"
  spec.add_dependency "view_component", ">= 4.0", "< 5"
  spec.add_dependency "yard", "~> 0.9.37"
end
