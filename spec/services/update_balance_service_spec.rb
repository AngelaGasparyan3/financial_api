# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateBalanceService do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, balance: 100.0) }

  describe '#call' do
    it 'updates the balance successfully' do
      service = UpdateBalanceService.new(account, 200.0)
      result = service.call

      expect(result[:success]).to be true
      expect(account.reload.balance).to eq(200.0)
    end

    it 'fails to update balance with invalid value' do
      allow(account).to receive(:update).and_return(false)
      service = UpdateBalanceService.new(account, 200.0)
      result = service.call

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Failed to update balance')
    end
  end
end
