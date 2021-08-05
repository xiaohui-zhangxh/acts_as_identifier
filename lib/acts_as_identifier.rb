# frozen_string_literal: true

require 'acts_as_identifier/version'
require 'xencoder'

module ActsAsIdentifier

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # == Automatically generate unique string based on id
    #
    # @param attr [String, Symbol] column name, default: :identifier
    # @param seed [Integer] Random seed, default: 1
    # @param length [Integer] length of identifier, default: 6
    # @params prefix [String, Symbol] add prefix to value, default: nil
    # @params id_column [String, Symbol] column name of id, default: :id
    # @params chars [String] chars for generating identifier
    def acts_as_identifier(attr = :identifier,
                           seed: 1,
                           length: 6,
                           prefix: nil,
                           id_column: :id,
                           chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
      define_singleton_method "#{attr}_encoder" do
        vname = "@#{attr}_encoder"
        return instance_variable_get(vname) if instance_variable_defined?(vname)

        instance_variable_set(vname, Xencoder.new(chars, length: length, seed: seed))
      end

      define_singleton_method "decode_#{attr}" do |str|
        if prefix
          return nil unless str.to_s.start_with?(prefix)
          str = str[prefix.length..-1]
        end
        str && send("#{attr}_encoder").decode(str)
      end

      define_singleton_method "encode_#{attr}" do |num|
        "#{prefix}#{send("#{attr}_encoder").encode(num)}"
      end

      define_method "acts_as_identifier__update_#{attr}" do
        update_column attr, self.class.send("encode_#{attr}", send(id_column))
      end

      before_commit :"acts_as_identifier__update_#{attr}", if: -> { previous_changes.key?(id_column.to_s) && !destroyed? }
    end
  end
end
