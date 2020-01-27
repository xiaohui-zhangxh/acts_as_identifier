# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

def setup_active_record
  db_path = File.expand_path('db/test.sqlite3', __dir__)
  File.delete(db_path) if File.exist?(db_path)

  ActiveRecord::Base.establish_connection adapter: 'sqlite3',
                                          database: db_path
  ActiveRecord::Base.logger = Logger.new(File.expand_path('../log/test.log', __dir__))
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define(version: 1) do
    create_table :accounts do |t|
      t.string :name
      t.string :kind
      t.string :group
      t.string :identifier
      t.string :slug
      t.string :str2
    end
  end
end

RSpec.describe ActsAsIdentifier do
  it do
    klass = Class.new
    klass.send :include, described_class
    expect(klass).to respond_to :acts_as_identifier
  end

  context 'with active record' do
    before { setup_active_record }

    context 'with default option' do
      before do
        @model = Class.new(ActiveRecord::Base) do
          include ActsAsIdentifier
          self.table_name = 'accounts'
          acts_as_identifier
        end
      end

      it 'identifier should not be nil' do
        expect(@model.create.identifier).not_to be_nil
      end

      it 'default identifier length should be 6' do
        expect(@model.create.identifier.length).to eq 6
      end

      it { expect(@model.encode_identifier(1)).to eq 'EPaPaP' }
      it { expect(@model.encode_identifier(2)).to eq 'HSo0u4' }

      it do
        record = @model.create
        expect(@model.decode_identifier(record.identifier)).to eq record.id
      end

      it do
        record = @model.create(id: 1)
        expect(record.identifier).to eq 'EPaPaP'
        record.update id: 2
        expect(record.identifier).to eq 'HSo0u4'
        record.update name: 'hello'
        expect(record.identifier).to eq 'HSo0u4'
      end

      it do
        record = @model.create
        expect { record.destroy }.not_to raise_error
      end
    end

    context 'with length = 10' do
      before do
        @model = Class.new(ActiveRecord::Base) do
          include ActsAsIdentifier
          self.table_name = 'accounts'
          acts_as_identifier length: 10
        end
      end
      it { expect(@model.create.identifier.length).to eq 10 }
    end

    context 'with multiple identifier' do
      before do
        model = Class.new(ActiveRecord::Base) do
          include ActsAsIdentifier
          self.table_name = 'accounts'
          acts_as_identifier length: 11
          acts_as_identifier :slug, length: 5
          acts_as_identifier :str2, length: 8
        end
        @record = model.create
      end

      it { expect(@record.identifier.length).to eq 11 }
      it { expect(@record.slug.length).to eq 5 }
      it { expect(@record.str2.length).to eq 8 }
      it { expect(@record.class.decode_identifier(@record.identifier)).to eq @record.id }
    end

    context 'with prefix' do
      before do
        model = Class.new(ActiveRecord::Base) do
          include ActsAsIdentifier
          self.table_name = 'accounts'
          acts_as_identifier :slug, prefix: 'u-', length: 6
        end
        @record = model.create
      end

      it { expect(@record.slug).to be_start_with('u-') }
      it { expect(@record.slug.length).to eq(8) }
      it { expect(@record.class.decode_slug(@record.slug)).to eq @record.id }
    end
  end
end
