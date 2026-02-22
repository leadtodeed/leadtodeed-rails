# frozen_string_literal: true

module Leadtodeed
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Leadtodeed

      initializer "leadtodeed.importmap", before: "importmap" do |app|
        app.config.importmap.paths << Engine.root.join("config/importmap.rb") if app.config.respond_to?(:importmap)
      end

      initializer "leadtodeed.assets" do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.paths << Engine.root.join("app/javascript")
          app.config.assets.paths << Engine.root.join("vendor/javascript")
        end
      end

      initializer "leadtodeed.helpers" do
        ActiveSupport.on_load(:action_controller_base) do
          helper Leadtodeed::WidgetHelper
        end
      end
    end
  end
end
