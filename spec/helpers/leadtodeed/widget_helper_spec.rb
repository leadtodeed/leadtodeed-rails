# frozen_string_literal: true

RSpec.describe Leadtodeed::WidgetHelper, type: :helper do
  describe "#leadtodeed_widget_tag" do
    context "when user is not signed in" do
      before { allow(helper).to receive(:user_signed_in?).and_return(false) }

      it "returns nil" do
        expect(helper.leadtodeed_widget_tag).to be_nil
      end
    end

    context "when user is signed in" do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:javascript_import_module_tag)
          .with("leadtodeed-widget-init")
          .and_return("<script>import</script>".html_safe)
      end

      it "renders meta tags with default color" do
        ENV.delete("LEADTODEED_PRIMARY_COLOR")
        result = helper.leadtodeed_widget_tag
        expect(result).to include('name="leadtodeed-primary-color"')
        expect(result).to include('content="#8B5CF6"')
      end

      it "renders meta tag for backend URL" do
        ENV["LEADTODEED_BACKEND_URL"] = "https://example.com"
        result = helper.leadtodeed_widget_tag
        expect(result).to include('name="leadtodeed-url"')
        expect(result).to include('content="https://example.com"')
      ensure
        ENV.delete("LEADTODEED_BACKEND_URL")
      end

      it "uses custom primary color when provided" do
        result = helper.leadtodeed_widget_tag(primary_color: "#FF0000")
        expect(result).to include('content="#FF0000"')
      end

      it "uses ENV primary color when set" do
        ENV["LEADTODEED_PRIMARY_COLOR"] = "#00FF00"
        result = helper.leadtodeed_widget_tag
        expect(result).to include('content="#00FF00"')
      ensure
        ENV.delete("LEADTODEED_PRIMARY_COLOR")
      end
    end
  end
end
