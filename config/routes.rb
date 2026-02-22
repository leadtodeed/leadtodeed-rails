# frozen_string_literal: true

Leadtodeed::Rails::Engine.routes.draw do
  resource :token, only: [:create]
end
