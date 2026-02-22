# frozen_string_literal: true

module Leadtodeed
  module WidgetHelper
    def leadtodeed_widget_tag
      return unless user_signed_in?

      javascript_import_module_tag("leadtodeed-widget")
    end
  end
end
