# frozen_string_literal: true

module Leadtodeed
  module WidgetHelper
    def leadtodeed_widget_tag(primary_color: nil)
      return unless user_signed_in?

      color = primary_color || ENV.fetch("LEADTODEED_PRIMARY_COLOR", "#8B5CF6")

      tag.meta(name: "leadtodeed-url", content: ENV.fetch("LEADTODEED_BACKEND_URL", nil)) +
        tag.meta(name: "leadtodeed-primary-color", content: color) +
        javascript_import_module_tag("leadtodeed-widget-init")
    end
  end
end
