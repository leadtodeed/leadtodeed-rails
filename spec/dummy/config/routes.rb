# frozen_string_literal: true

Rails.application.routes.draw do
  mount Leadtodeed::Rails::Engine => "/api/leadtodeed"
end
