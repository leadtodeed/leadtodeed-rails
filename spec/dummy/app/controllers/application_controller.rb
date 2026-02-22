# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_forgery_protection

  attr_reader :current_user

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    head :unauthorized unless user_signed_in?
  end

  helper_method :current_user, :user_signed_in?
end
