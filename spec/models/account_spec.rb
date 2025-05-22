# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:outgoing_transfers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:incoming_transfers).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:account) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_uniqueness_of(:number) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  end

  describe '#sufficient_funds?' do
    let(:account) { build(:account, balance: 100.0) }

    it 'returns true if balance is sufficient' do
      expect(account.sufficient_funds?(50.0)).to be true
    end

    it 'returns true if balance equals the amount' do
      expect(account.sufficient_funds?(100.0)).to be true
    end

    it 'returns false if balance is insufficient' do
      expect(account.sufficient_funds?(150.0)).to be false
    end
  end
end
