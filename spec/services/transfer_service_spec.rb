require 'rails_helper'

RSpec.describe TransferService do
  let(:sender) { create(:user, balance: 100.0) }
  let(:recipient) { create(:user, balance: 50.0) }

  describe '#call' do
    it 'successfully transfers funds' do
      service = TransferService.new(sender, recipient, 30.0)
      service.call

      expect(sender.reload.balance).to eq(70.0)
      expect(recipient.reload.balance).to eq(80.0)
    end

    it 'raises an error for insufficient funds' do
      service = TransferService.new(sender, recipient, 200.0)
      expect { service.call }.to raise_error('Insufficient funds...')
    end
  end
end
