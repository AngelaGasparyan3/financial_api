# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticateUserService do
  let(:user) { create(:user, email: 'test@example.com', password: 'password') }

  describe '#call' do
    it 'authenticates user with valid credentials' do
      service = AuthenticateUserService.new(user.email, 'password')
      result = service.call

      expect(result[:success]).to be true
      expect(result[:token]).to be_present
    end

    it 'fails with invalid credentials' do
      service = AuthenticateUserService.new(user.email, 'wrong_password')
      result = service.call

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Invalid credentials')
    end
  end
end
