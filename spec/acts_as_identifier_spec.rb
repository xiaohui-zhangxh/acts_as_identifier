# frozen_string_literal: true

require 'acts_as_identifier'
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
      t.string :str1
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
          acts_as_identifier :str1, length: 6
          acts_as_identifier :str2, length: 8, case_sensitive: false
        end
        @record = model.create
      end

      it { expect(@record.identifier.length).to eq 10 }
      it { expect(@record.str1.length).to eq 6 }
      it { expect(@record.str2.length).to eq 8 }
    end

    context do
      before do
        allow(SecureRandom).to receive(:alphanumeric).and_return('AbC123')
        allow(SecureRandom).to receive(:hex).and_return('abc123')
      end

      context 'when case sensitive' do
        before do
          model = Class.new(ActiveRecord::Base) do
            self.table_name = 'accounts'
            acts_as_identifier case_sensitive: true
          end
          @record = model.create
        end
        it { expect(@record.identifier).to eq 'AbC123' }
      end

      context 'when case insensitive' do
        before do
          model = Class.new(ActiveRecord::Base) do
            self.table_name = 'accounts'
            acts_as_identifier case_sensitive: false
          end
          @record = model.create
        end
        it { expect(@record.identifier).to eq 'abc123' }
      end

      context 'with uniqueness' do
        before do
          @model = Class.new(ActiveRecord::Base) do
            self.table_name = 'accounts'
            acts_as_identifier case_sensitive: false, scope: %i[kind group], max_loop: 3
          end
          @model.create(kind: 'foo', group: 'bar')
        end

        it { expect { @model.create(kind: 'foo', group: 'bar') }.to raise_error(ActsAsIdentifier::LoopTooManyTimesError) }

        it { expect { @model.create(kind: 'foo') }.not_to raise_error }
        it { expect { @model.create }.not_to raise_error }
      end

      context 'with prefix' do
        before do
          model = Class.new(ActiveRecord::Base) do
            self.table_name = 'accounts'
            acts_as_identifier prefix: 'u-', length: 6
          end
          @record = model.create
        end

        it { expect(@record.identifier).to be_start_with('u-') }
        it { expect(@record.identifier.length).to eq(8) }
      end
    end
  end
end
