# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ActsAsIdentifier::XbaseInteger do
  let(:subject) { described_class.new('0123456789abcdef'.chars) }

  it { expect(subject.to_x(16)).to eq 16.to_s(16) }
  it { expect(subject.to_x(100)).to eq 100.to_s(16) }
  it { expect(subject.to_i(16.to_s(16))).to eq 16 }
  it { expect(subject.to_i(100.to_s(16))).to eq 100 }

  context 'with binary' do
    let(:subject) { described_class.new('01'.chars) }
    it { expect(subject.to_x(16)).to eq 16.to_s(2) }
    it { expect(subject.to_x(100)).to eq 100.to_s(2) }
    it { expect(subject.to_i(16.to_s(2))).to eq 16 }
    it { expect(subject.to_i(100.to_s(2))).to eq 100 }
  end

  context 'with base 8' do
    let(:subject) { described_class.new('01234567'.chars) }
    it { expect(subject.to_x(16)).to eq 16.to_s(8) }
    it { expect(subject.to_x(100)).to eq 100.to_s(8) }
    it { expect(subject.to_i(16.to_s(8))).to eq 16 }
    it { expect(subject.to_i(100.to_s(8))).to eq 100 }
  end

  context 'with base 36' do
    let(:subject) { described_class.new('0123456789abcdefghijklmnopqrstuvwxyz'.chars) }
    it { expect(subject.to_x(16)).to eq 16.to_s(36) }
    it { expect(subject.to_x(100)).to eq 100.to_s(36) }
    it { expect(subject.to_i(16.to_s(36))).to eq 16 }
    it { expect(subject.to_i(100.to_s(36))).to eq 100 }
  end

  context 'with base 62' do
    let(:subject) { described_class.new('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars) }
    it { expect(subject.to_x(16)).to eq 'g' }
    it { expect(subject.to_x(100)).to eq '1C' }
    it { expect(subject.to_x(1000)).to eq 'g8' }
    it { expect(subject.to_x(10000)).to eq '2Bi' }
    it { expect(subject.to_x(10000000)).to eq 'FXsk' }
    it { expect(subject.to_x(10000000000)).to eq 'aUKYOA' }
    it { expect(subject.to_i('g')).to eq 16 }
    it { expect(subject.to_i('1C')).to eq 100 }
    it { expect(subject.to_i('g8')).to eq 1000 }
    it { expect(subject.to_i('2Bi')).to eq 10000 }
    it { expect(subject.to_i('FXsk')).to eq 10000000 }
    it { expect(subject.to_i('aUKYOA')).to eq 10000000000 }
  end
end
