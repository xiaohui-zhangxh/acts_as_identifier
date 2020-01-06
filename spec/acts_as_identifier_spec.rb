# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

ActiveRecord::Base.include ActsAsIdentifier

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
  it { expect(described_class).to be_const_defined :LoopTooManyTimesError }
  it do
    klass = Class.new
    klass.send :include, described_class
    expect(klass).to respond_to :acts_as_identifier
  end

  context 'with active record' do
    before { setup_active_record }

    it do
      expect {
        model = Class.new(ActiveRecord::Base) do
          self.table_name = 'accounts'
          acts_as_identifier chars: '0123'.chars, mappings: '01234'.chars
        end
      }.to raise_error /chars and mappings must have the same characters/
    end

    it do
      expect {
        model = Class.new(ActiveRecord::Base) do
          self.table_name = 'accounts'
          acts_as_identifier chars: '0123'
        end
      }.to raise_error /chars must be an array/
    end

    it do
      expect {
        model = Class.new(ActiveRecord::Base) do
          self.table_name = 'accounts'
          acts_as_identifier mappings: '0123'
        end
      }.to raise_error /mappings must be an array/
    end

    context 'with default option' do
      before do
        @model = Class.new(ActiveRecord::Base) do
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

      it { expect(@model.encode_identifier(1)).to eq 'HuF2Od' }
      it { expect(@model.encode_identifier(2)).to eq 'g3SIB8' }

      it do
        record = @model.create
        expect(@model.decode_identifier(record.identifier)).to eq record.id
      end

      it do
        record = @model.create(id: 1)
        expect(record.identifier).to eq 'HuF2Od'
        record.update id: 2
        expect(record.identifier).to eq 'g3SIB8'
        record.update name: 'hello'
        expect(record.identifier).to eq 'g3SIB8'
      end
    end

    context 'with length = 10' do
      before do
        @model = Class.new(ActiveRecord::Base) do
          self.table_name = 'accounts'
          acts_as_identifier length: 10
        end
      end
      it { expect(@model.create.identifier.length).to eq 10 }
    end

    context 'with multiple identifier' do
      before do
        model = Class.new(ActiveRecord::Base) do
          self.table_name = 'accounts'
          acts_as_identifier length: 10
          acts_as_identifier :slug, length: 6
          acts_as_identifier :str2, length: 8
        end
        @record = model.create
      end

      it { expect(@record.identifier.length).to eq 10 }
      it { expect(@record.slug.length).to eq 6 }
      it { expect(@record.str2.length).to eq 8 }
      it { expect(@record.class.decode_identifier(@record.identifier)).to eq @record.id }
    end

    context do
      context 'with prefix' do
        before do
          model = Class.new(ActiveRecord::Base) do
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
end
