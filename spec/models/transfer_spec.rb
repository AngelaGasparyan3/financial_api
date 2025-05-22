# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transfer, type: :model do
  let(:user) { create(:user) }
  let(:from_account) { create(:account, user: user, balance: 500.0) }
  let(:to_account) { create(:account, user: user, balance: 100.0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      transfer = build(:transfer, from_account: from_account, to_account: to_account, amount: 100.0, status: 'created')
      expect(transfer).to be_valid
    end

    it 'is invalid when from_account equals to_account' do
      transfer = build(:transfer, from_account: from_account, to_account: from_account)
      expect(transfer).to be_invalid
      expect(transfer.errors[:to_account_id]).to include("can't be the same as from_account_id")
    end

    it 'is invalid without from_account' do
      transfer = build(:transfer, from_account: nil, to_account: to_account)
      expect(transfer).to be_invalid
      expect(transfer.errors[:from_account]).to include('must exist')
    end

    it 'is invalid without to_account' do
      transfer = build(:transfer, from_account: from_account, to_account: nil)
      expect(transfer).to be_invalid
      expect(transfer.errors[:to_account]).to include('must exist')
    end

    it 'is invalid with non-positive amount' do
      transfer = build(:transfer, from_account: from_account, to_account: to_account, amount: 0)
      expect(transfer).to be_invalid
      expect(transfer.errors[:amount]).to include('must be greater than 0')
    end
  end

  describe 'enums' do
    it 'has correct statuses' do
      expect(described_class.statuses.keys).to match_array(%w[created pending completed failed])
    end
  end

  describe 'status transition methods' do
    let(:transfer) { create(:transfer, from_account: from_account, to_account: to_account, amount: 100.0) }

    it 'changes status to pending' do
      transfer.pending!
      expect(transfer.reload.status).to eq('pending')
    end

    it 'changes status to completed' do
      transfer.completed!
      expect(transfer.reload.status).to eq('completed')
    end

    it 'changes status to failed' do
      transfer.failed!
      expect(transfer.reload.status).to eq('failed')
    end

    it 'checks for status predicates' do
      transfer.update!(status: 'failed')
      expect(transfer.failed?).to be true
      expect(transfer.completed?).to be false
      expect(transfer.pending?).to be false
    end
  end
end
