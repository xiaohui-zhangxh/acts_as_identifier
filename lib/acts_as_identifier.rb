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
    # @param length [Integer] length of identifier, default: 6
    # @params prefix [String, Symbol] add prefix to value, default: ''
    # @params id_column [String, Symbol] column name of id, default: :id
    # @params chars [Array<String>] chars
    # @params mappings [Array<String>] mappings must have the same characters as chars
    def acts_as_identifier(attr = :identifier,
                           seed: 1,
                           length: 6,
                           prefix: '',
                           id_column: :id,
                           chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
      define_singleton_method "#{attr}_encoder" do
        vname = "@#{attr}_encoder"
        return instance_variable_get(vname) if instance_variable_defined?(vname)

        instance_variable_set(vname, Xencoder.new(chars, length: length, seed: seed))
      end

      define_singleton_method "decode_#{attr}" do |str|
        send("#{attr}_encoder").decode(str[prefix.length..-1])
      end

      define_singleton_method "encode_#{attr}" do |num|
        "#{prefix}#{send("#{attr}_encoder").encode(num)}"
      end

      before_commit do |record|
        if record.previous_changes.key?(id_column.to_s) && !record.destroyed?
          record.update_column attr, self.class.send("encode_#{attr}", record.send(id_column))
        end
      end
    end
  end
end
