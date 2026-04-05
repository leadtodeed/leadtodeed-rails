# frozen_string_literal: true

require_relative "lib/leadtodeed/rails/version"

Gem::Specification.new do |spec|
  spec.name = "leadtodeed-rails"
  spec.version = Leadtodeed::Rails::VERSION
  spec.authors = ["Vlad Bokov"]
  spec.email = ["vlad@razum2um.me"]

  spec.summary = "Leadtodeed click-to-call phone widget integration for Rails"
  spec.description = "Rails engine providing WebRTC click-to-call functionality via Leadtodeed backend"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir[
    "lib/**/*",
    "app/**/*",
    "config/**/*",
    "vendor/**/*",
    "LICENSE.txt",
    "README.md"
  ]
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "importmap-rails"
  spec.add_dependency "jwt", ">= 2.5"
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "slim-rails"
end
