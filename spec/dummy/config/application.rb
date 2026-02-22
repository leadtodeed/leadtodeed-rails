# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "importmap-rails"
require "leadtodeed/rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "test-secret-key-base-for-specs"
    config.autoload_paths << File.expand_path("../app/controllers", __dir__)
  end
end
