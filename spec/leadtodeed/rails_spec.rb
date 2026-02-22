# frozen_string_literal: true

RSpec.describe Leadtodeed::Rails do
  it "has a version number" do
    expect(Leadtodeed::Rails::VERSION).not_to be_nil
  end

  it "defines the Leadtodeed::Rails::Engine class" do
    expect(Leadtodeed::Rails::Engine).to be < Rails::Engine
  end

  it "isolates the Leadtodeed namespace" do
    expect(Leadtodeed::Rails::Engine.isolated?).to be true
  end
end
