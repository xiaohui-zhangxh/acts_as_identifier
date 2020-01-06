# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ActsAsIdentifier::Encoder do
  let(:subject) do
    described_class.new(
      chars: '0123456789abcdef'.chars,
      mappings: '0123456789abcdef'.chars,
      length: 3
    )
  end

  it { expect(subject.base).to eq 256 } # '100'.to_i(16)
  it { expect(subject.max).to eq 3839 } # 'eff'.to_i(16)

  [0, 100, 1000].each do |i|
    it { expect(subject.encode(i).length).to eq 3 }
  end

  it { expect(subject.encode(3839).length).to eq 3 }
  it { expect(subject.encode(3840).length).to eq 4 }

  it do
    expect do
      0.upto(10_000).each do |i|
        raise 'not equal' unless subject.decode(subject.encode(i)) == i
      end
    end.not_to raise_error
  end

  context "with base 62" do
    let(:subject) do
      described_class.new(
        chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars,
        mappings: 'r5SdwDMU7lRH34CocZAxnFJ1G8yQ0tTfNOXs6hvqIu9iWBaLE2pKkVemjgYbPz'.chars,
        length: 8
      )
    end

    it { expect(subject.base).to eq 3_521_614_606_208 }
    it { expect(subject.max).to eq 214_818_490_978_687 }

    [0, 1_000, 1_000_000, 1_000_000_000].each do |i|
      it { expect(subject.encode(i).length).to eq 8 }
    end

    it { expect(subject.encode(214818490978687).length).to eq 8 }
    it { expect(subject.encode(214818490978688).length).to eq 9 }

    it do
      expect do
        0.upto(10_000).each do |i|
          raise 'not equal' unless subject.decode(subject.encode(i)) == i
        end
        214818490970000.upto(214818490978687).each do |i|
          raise 'not equal' unless subject.decode(subject.encode(i)) == i
        end
      end.not_to raise_error
    end

    if ENV['EXTRA_TEST']
      a, b = ENV['EXTRA_TEST'].split(',').map(&:to_i)
      it "extra test from #{a} to #{b}" do
        expect do
          a.upto(b).each do |i|
            raise 'not equal' unless subject.decode(subject.encode(i)) == i
          end
        end.not_to raise_error
      end
    end
  end
end
