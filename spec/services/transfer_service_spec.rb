# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferService do
  let(:user) { create(:user) }
  let(:from_account) { create(:account, user: user, balance: 500) }
  let(:to_account) { create(:account, balance: 300) }
  let(:amount) { 100 }

  subject(:service) { described_class.new(from_account, to_account, amount) }

  describe '#call' do
    context 'when all conditions are valid' do
      it 'transfers the money successfully' do
        result = service.call

        expect(result[:success]).to be true
        expect(result[:transfer]).to be_persisted
        expect(result[:transfer].status).to eq('created')
        expect(result[:transfer].amount).to eq(amount)
        expect(result[:transfer].from_account).to eq(from_account)
        expect(result[:transfer].to_account).to eq(to_account)

        # Check balances were updated
        expect(from_account.reload.balance).to eq(400)
        expect(to_account.reload.balance).to eq(400)
      end
    end

    context 'when there are insufficient funds' do
      let(:amount) { 600 }

      it 'does not transfer and returns an error' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Insufficient funds')
        expect(result[:transfer]).to be_persisted
        expect(result[:transfer].status).to eq('failed')

        expect(from_account.reload.balance).to eq(500)
        expect(to_account.reload.balance).to eq(300)
      end
    end

    context 'when the amount is zero or negative' do
      let(:amount) { 0 }

      it 'returns an error' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Amount must be greater than zero')
      end

      it 'does not create a transfer record' do
        expect do
          service.call
        end.not_to change(Transfer, :count)
      end
    end

    context 'when the recipient account does not exist' do
      let(:to_account) { nil }

      it 'returns an error' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Recipient account not found')
      end

      it 'does not create a transfer record' do
        expect do
          service.call
        end.not_to change(Transfer, :count)
      end
    end

    context 'when the sender account does not exist' do
      let(:from_account) { nil }

      it 'returns an error' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Sender account not found')
      end

      it 'does not create a transfer record' do
        expect do
          service.call
        end.not_to change(Transfer, :count)
      end
    end
  end
end
