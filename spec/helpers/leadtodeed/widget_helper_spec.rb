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
          .with("leadtodeed-widget")
          .and_return("<script>import</script>".html_safe)
      end

      it "renders the import module tag" do
        result = helper.leadtodeed_widget_tag
        expect(result).to include("<script>import</script>")
      end
    end
  end
end
