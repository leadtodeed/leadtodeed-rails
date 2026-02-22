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
    context "when not signed in" do
      it "redirects to sign in" do
        post "/api/leadtodeed/token", headers: { "HOST" => "127.0.0.1" }

        expect(response).to redirect_to(new_user_session_url)
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

      it "returns a JWT token with user_id" do
        post "/api/leadtodeed/token", headers: { "HOST" => "127.0.0.1" }

        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json).to have_key("token")

        decoded = JWT.decode(json["token"], "test-secret", true, algorithm: "HS256").first
        expect(decoded["sub"]).to eq(user.email)
        expect(decoded["user_id"]).to eq(user.id)
        expect(decoded["name"]).to eq(user.name)
        expect(decoded["exp"]).to be_present
        expect(decoded["iat"]).to be_present
      end
    end
  end
end
