# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts API', type: :request do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, balance: 500) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /accounts/:id' do
    context 'when the account belongs to the user' do
      it 'returns the account' do
        get "/accounts/#{account.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(account.id)
        expect(json_response['number']).to eq(account.number)
        expect(json_response['name']).to eq(account.name)
        expect(json_response['balance']).to eq(account.balance.to_f)
      end
    end

    context 'when the account does not belong to the user' do
      let(:other_user) { create(:user) }
      let!(:other_account) { create(:account, user: other_user) }

      it 'returns not found' do
        get "/accounts/#{other_account.id}", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to eq('Account not found')
        expect(json_response['code']).to eq('ACCOUNT_NOT_FOUND')
      end
    end

    context 'when the account does not exist' do
      it 'returns not found' do
        get '/accounts/0', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to eq('Account not found')
        expect(json_response['code']).to eq('ACCOUNT_NOT_FOUND')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get "/accounts/#{account.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /accounts/:id/update_balance' do
    context 'when the update is valid' do
      it 'updates the balance' do
        patch "/accounts/#{account.id}/update_balance",
              params: { account: { balance: 1000.0 } },
              headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Balance updated')
        expect(json_response['account']['balance']).to eq(1000.0)

        expect(account.reload.balance).to eq(1000.0)
      end
    end

    context 'when the update is invalid' do
      let(:update_service) { instance_double(UpdateBalanceService) }

      before do
        allow(UpdateBalanceService).to receive(:new).and_return(update_service)
        allow(update_service).to receive(:call).and_return({ success: false, error: 'Failed to update balance' })
      end

      it 'returns an error' do
        patch "/accounts/#{account.id}/update_balance",
              params: { account: { balance: nil } },
              headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['message']).to eq('Failed to update balance')
        expect(json_response['code']).to eq('UPDATE_FAILED')
      end
    end

    context 'when the account does not belong to the user' do
      let(:other_user) { create(:user) }
      let!(:other_account) { create(:account, user: other_user) }

      it 'returns not found' do
        patch "/accounts/#{other_account.id}/update_balance",
              params: { balance: 1000 },
              headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to eq('Account not found')
        expect(json_response['code']).to eq('ACCOUNT_NOT_FOUND')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        patch "/accounts/#{account.id}/update_balance", params: { balance: 1000 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def json_response
    response.parsed_body
  end
end
