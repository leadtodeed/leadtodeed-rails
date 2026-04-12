# frozen_string_literal: true

# LEADTODEED_WIDGET_URL overrides the vendored asset with an external URL
# (e.g. a CDN-hosted build at https://leadtodeed.ai/widget/{hash}/leadtodeed-widget.js).
# Read at app boot so the host's main importmap renders the right URL — inline
# override scripts after javascript_importmap_tags don't take effect because the
# browser has already resolved the import map.
override_url = ENV.fetch("LEADTODEED_WIDGET_URL", nil)
if override_url.present?
  pin "leadtodeed-widget", to: override_url, preload: false
else
  pin "leadtodeed-widget", to: "leadtodeed-widget.js", preload: false
end
