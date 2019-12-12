# frozen_string_literal: true

require 'securerandom'
require 'acts_as_identifier/version'

module ActsAsIdentifier
  LoopTooManyTimesError = Class.new(StandardError)

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # == Automatically generate unique secure random string
    #
    # @param attr [String, Symbol] column name, default: :identifier
    # @param length [Integer] length of identifier, default: 6
    # @param case_sensitive [Boolean] Case-sensitive? default: true
    # @param max_loop [Integer] max loop count to generate unique identifier, in case of running endless loop, default: 100
    # @param scope [Array<Symbol,String>] scope of identifier, default: []
    # @params prefix [String, Symbol] add prefix to value, default: ''
    def acts_as_identifier(attr = nil, length: 6, case_sensitive: true, max_loop: 100, scope: [], prefix: '')
      attr ||= :identifier
      scope = Array(scope)
      method = case_sensitive ? :alphanumeric : :hex
      length /= 2 if method == :hex

      before_create do
        query = self.class.unscoped.where(scope.inject({}) { |memo, i| memo.merge(i => send(i)) })
        n = 0
        loop do
          n += 1
          value = send("#{attr}=", "#{prefix}#{SecureRandom.send(method, length)}")
          break unless query.where(attr => value).exists?
          raise LoopTooManyTimesError if n > max_loop
        end
      end
    end
  end
end

require 'acts_as_identifier/railtie' if defined?(Rails)
