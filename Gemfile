# frozen_string_literal: true

source "https://rubygems.org"
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "~> 8.1.0")
gem "rails", rails_version == "main" ? { github: "rails/rails", branch: "main" } : rails_version
# Before 8.1, Rails' JSON encoder passes `quirks_mode`, which json 3 removed.
gem "json", "< 3" if rails_version.match?(/\A~> (7\.|8\.0)/)

gem "capybara", "~> 3.40"
gem "dry-initializer", "~> 3.1"
gem "dry-types", "~> 1.7"
gem "rake", "~> 13.0"
gem "rspec-rails", ">= 6.1"
gem "rubocop", "~> 1.79"
gem "rubocop-rails", "~> 2.30"
gem "rubocop-rspec", "~> 3.6"
gem "simplecov", "~> 0.22"
gem "simplecov-console", "~> 0.9"
gem "view_component-contrib", "~> 0.2"
