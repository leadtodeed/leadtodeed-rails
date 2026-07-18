# frozen_string_literal: true

# NOTE: This spec is designed to run from the host Rails app context.
# Run it from the host app directory:
#   bundle exec rspec <path-to-engine>/spec/requests/leadtodeed/tokens_spec.rb

require "rails_helper"

RSpec.describe "Leadtodeed::Tokens" do
  let(:agency) { create(:agency) }
  let(:user) { create(:agent, agency: agency) }

  before { host! ENV.fetch("APP_HOST", "127.0.0.1:5000") }

  describe "POST /api/leadtodeed/token" do
    context "when no principal is resolved" do
      it "returns unauthorized" do
        post "/api/leadtodeed/token", headers: { "HOST" => "127.0.0.1" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in" do
      before do
        sign_in user
        ENV["LEADTODEED_JWT_SECRET"] = "test-secret"
      end

      after do
        ENV.delete("LEADTODEED_JWT_SECRET")
      end

      it "mints a JWT from the user's #leadtodeed_attributes" do
        post "/api/leadtodeed/token", headers: { "HOST" => "127.0.0.1" }

        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json).to have_key("token")

        decoded = JWT.decode(json["token"], "test-secret", true, algorithm: "HS256").first
        expect(decoded["sub"]).to eq(user.id.to_s)
        expect(decoded["name"]).to eq(user.display_name)
        expect(decoded["aud"]).to eq(Rails.application.config.leadtodeed_jwt_aud)
        expect(decoded["exp"]).to be_present
        expect(decoded["iat"]).to be_present
      end
    end
  end
end
