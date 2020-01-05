# frozen_string_literal: true

require 'securerandom'
require 'acts_as_identifier/version'
require 'acts_as_identifier/xbase_integer'
require 'acts_as_identifier/encoder'

module ActsAsIdentifier
  LoopTooManyTimesError = Class.new(StandardError)

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # == Automatically generate unique string based on id
    #
    # @param attr [String, Symbol] column name, default: :identifier
    # @param length [Integer] length of identifier, default: 6
    # @params prefix [String, Symbol] add prefix to value, default: ''
    # @params id_column [String, Symbol] column name of id, default: :id
    # @params chars [Array<String>] chars
    # @params mappings [Array<String>] mappings must have the same characters as chars
    def acts_as_identifier(attr = :identifier,
                           length: 6,
                           prefix: '',
                           id_column: :id,
                           chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars,
                           mappings: '3NjncZg82M5fe1PuSABJG9kiRQOqlVa0ybKXYDmtTxCp6Lh7rsIFUWd4vowzHE'.chars)
      raise 'chars must be an array' unless chars.is_a?(Array)
      raise 'mappings must be an array' unless chars.is_a?(Array)
      unless (chars - mappings).empty? && (mappings - chars).empty?
        raise 'chars and mappings must have the same characters'
      end

      encoder = Encoder.new(chars: chars, mappings: mappings, length: length)

      define_singleton_method "decode_#{attr}" do |str|
        encoder.decode(str[prefix.length..-1])
      end

      define_singleton_method "encode_#{attr}" do |num|
        "#{prefix}#{encoder.encode(num)}"
      end

      after_create_commit do |record|
        record.update_column attr, self.class.send("encode_#{attr}", record.send(id_column))
      end
    end
  end
end

require 'acts_as_identifier/railtie' if defined?(Rails)
