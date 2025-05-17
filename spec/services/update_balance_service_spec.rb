require 'rails_helper'

RSpec.describe UpdateBalanceService do
  let(:user) { create(:user, balance: 100.0) }

  describe '#call' do
    it 'updates the balance successfully' do
      service = UpdateBalanceService.new(user, 200.0)
      result = service.call

      expect(result[:success]).to be true
      expect(user.reload.balance).to eq(200.0)
    end

    it 'fails to update balance with invalid value' do
      allow(user).to receive(:update).and_return(false)
      service = UpdateBalanceService.new(user, 200.0)
      result = service.call

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Failed to Update balance')
    end
  end
end
