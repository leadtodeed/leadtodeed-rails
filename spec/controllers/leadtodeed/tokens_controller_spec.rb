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

  def decode(token)
    JWT.decode(token, "test-secret", true, algorithm: "HS256").first
  end

  # A principal is anything that describes itself via #leadtodeed_attributes.
  def principal(attributes)
    Class.new do
      define_method(:leadtodeed_attributes) { attributes }
    end.new
  end

  def stub_on_controller(method, value)
    allow_any_instance_of(Leadtodeed::ApplicationController) # rubocop:disable RSpec/AnyInstance
      .to receive(method).and_return(value)
  end

  describe "POST /api/leadtodeed/token" do
    context "when no principal is resolved" do
      it "returns unauthorized" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when current_user describes itself via #leadtodeed_attributes" do
      before { stub_on_controller(:current_user, principal(sub: "user_1", name: "Test User", role: "agent")) }

      it "mints a JWT from #leadtodeed_attributes plus exp/iat" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:ok)

        claims = decode(response.parsed_body["token"])
        expect(claims["sub"]).to eq("user_1")
        expect(claims["name"]).to eq("Test User")
        expect(claims["role"]).to eq("agent")
        expect(claims["exp"]).to be_a(Integer)
        expect(claims["iat"]).to be_a(Integer)
      end
    end

    context "when current_user cannot describe itself" do
      before { stub_on_controller(:current_user, Struct.new(:id).new(1)) }

      it "returns unauthorized" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the host defines #current_leadtodeed_subject" do
      before { stub_on_controller(:current_leadtodeed_subject, principal(sub: "staff_9", name: "Ops Person")) }

      it "mints the token for that subject, not current_user" do
        post "/api/leadtodeed/token"
        expect(response).to have_http_status(:ok)

        claims = decode(response.parsed_body["token"])
        expect(claims["sub"]).to eq("staff_9")
        expect(claims["name"]).to eq("Ops Person")
      end
    end
  end
end
