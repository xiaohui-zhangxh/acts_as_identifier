# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ActsAsIdentifier::Railtie do
  before do
    ENV['DATABASE_URL'] = 'sqlite3://db/test.sqlite3'
    class DummyApplicatin < Rails::Application
      config.eager_load = false
    end

    Rails.application.initialize!
  end

  it { expect(ActiveRecord::Base).to respond_to :acts_as_identifier }
end
