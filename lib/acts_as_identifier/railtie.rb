# frozen_string_literal: true

module ActsAsIdentifier
  class Railtie < ::Rails::Railtie
    initializer 'acts_as_identifier' do
      ActiveSupport.on_load(:active_record) do
        include ActsAsIdentifier
      end
    end
  end
end
