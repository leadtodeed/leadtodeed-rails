# frozen_string_literal: true

module Leadtodeed
  module WidgetHelper
    # Renders the widget script tag for signed-in users.
    #
    # The widget is loaded via the host app's importmap. The "leadtodeed-widget"
    # pin is set in the gem's config/importmap.rb at boot — by default it points
    # at the vendored asset, but if ENV["LEADTODEED_WIDGET_URL"] is set, the pin
    # is replaced with that URL (e.g. a CDN-hosted build at
    # https://leadtodeed.ai/widget/{hash}/leadtodeed-widget.js). The override
    # must happen at boot because importmap rendering precedes any module
    # imports — late inline scripts won't take effect.
    def leadtodeed_widget_tag
      return unless user_signed_in?

      javascript_import_module_tag("leadtodeed-widget")
    end
  end
end
