# frozen_string_literal: true

module Leadtodeed
  class TokensController < ApplicationController
    # Access is decided by the acting principal, not authenticate_user!: whoever
    # the host resolves via #leadtodeed_subject mints a token, and no principal
    # is a plain 401. This lets any authenticated scope — a customer, a
    # back-office user — issue a token so long as it can describe itself through
    # #leadtodeed_attributes. skip_before_action clears the host's global
    # authenticate_user! (raise: false — a host may not have one).
    skip_before_action :authenticate_user!, raise: false

    def create
      subject = leadtodeed_subject
      return head :unauthorized unless subject

      claims = subject.leadtodeed_attributes.merge(
        exp: 8.hours.from_now.to_i,
        iat: Time.current.to_i
      )

      render json: { token: JWT.encode(claims, ENV.fetch("LEADTODEED_JWT_SECRET"), "HS256") }
    end

    private

    # The principal this token represents — anything responding to
    # #leadtodeed_attributes, which supplies the JWT claims (including `sub`).
    # Defaults to current_user; a host with more than one signed-in scope
    # defines #current_leadtodeed_subject to choose the acting one.
    def leadtodeed_subject
      subject =
        if respond_to?(:current_leadtodeed_subject, true)
          current_leadtodeed_subject
        else
          current_user
        end

      subject if subject.respond_to?(:leadtodeed_attributes)
    end
  end
end
