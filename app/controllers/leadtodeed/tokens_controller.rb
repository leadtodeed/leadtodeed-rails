# frozen_string_literal: true

module Leadtodeed
  class TokensController < ApplicationController
    before_action :authenticate_user!

    def create
      token = JWT.encode(
        user_attributes.merge(
          sub: current_user.id.to_s,
          exp: 8.hours.from_now.to_i,
          iat: Time.current.to_i
        ),
        ENV.fetch("LEADTODEED_JWT_SECRET"),
        "HS256"
      )

      render json: { token: token }
    end

    private

    def user_attributes
      if current_user.respond_to?(:leadtodeed_attributes) && current_user.leadtodeed_attributes.respond_to?(:merge)
        current_user.leadtodeed_attributes
      else
        {}
      end
    end
  end
end
