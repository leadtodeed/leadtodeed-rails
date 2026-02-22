# frozen_string_literal: true

require "jwt"

RSpec.describe Leadtodeed::TokensController, type: :request do
  before do
    ENV["LEADTODEED_JWT_SECRET"] = "test-secret"
    Rails.application.routes.draw do
      mount Leadtodeed::Rails::Engine => "/api/leadtodeed"
    end
  end

  after do
    ENV.delete("LEADTODEED_JWT_SECRET")
    Rails.application.reload_routes!
  end

  let(:user) do
    Struct.new(:id, :email, :name, keyword_init: true)
          .new(id: 1, email: "test@example.com", name: "Test User")
  end

  describe "POST /api/leadtodeed/token" do
    context "when not authenticated" do
      it "returns unauthorized" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      before do
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:user_signed_in?).and_return(true) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:authenticate_user!).and_return(true) # rubocop:disable RSpec/AnyInstance
      end

      it "returns a JWT token" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json).to have_key("token")
      end

      it "encodes correct claims in the JWT" do
        post "/api/leadtodeed/token"

        token = response.parsed_body["token"]
        decoded = JWT.decode(token, "test-secret", true, algorithm: "HS256").first

        expect(decoded["sub"]).to eq("1")
        expect(decoded["exp"]).to be_a(Integer)
        expect(decoded["iat"]).to be_a(Integer)
      end
    end

    context "when current_user responds to leadtodeed_attributes" do
      before do
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:user_signed_in?).and_return(true) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Leadtodeed::ApplicationController).to receive(:authenticate_user!).and_return(true) # rubocop:disable RSpec/AnyInstance
        allow(user).to receive(:respond_to?).and_call_original
        allow(user).to receive(:respond_to?).with(:leadtodeed_attributes).and_return(true)
        allow(user).to receive(:leadtodeed_attributes).and_return({ name: "LTD User", role: "agent" })
      end

      it "merges leadtodeed_attributes into the JWT" do
        post "/api/leadtodeed/token"

        token = response.parsed_body["token"]
        decoded = JWT.decode(token, "test-secret", true, algorithm: "HS256").first

        expect(decoded["sub"]).to eq("1")
        expect(decoded["name"]).to eq("LTD User")
        expect(decoded["role"]).to eq("agent")
      end
    end
  end
end
