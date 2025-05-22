# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transfers API', type: :request do
  let(:user) { create(:user) }
  let!(:from_account) { create(:account, user: user, balance: 500) }
  let!(:to_account) { create(:account, balance: 300) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST /transfers' do
    before do
      ActiveJob::Base.queue_adapter = :inline
    end
    context 'when the transfer is valid' do
      let(:valid_params) do
        {
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: 100
        }
      end

      it 'creates a transfer' do
        expect do
          post '/transfers', params: valid_params, headers: headers
          perform_enqueued_jobs
        end.to change(Transfer, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['transfer']['amount']).to eq('100.0')
        expect(json_response['transfer']['from_account_id']).to eq(from_account.id)
        expect(json_response['transfer']['to_account_id']).to eq(to_account.id)
        expect(json_response['transfer']['status']).to eq('created')

        expect(from_account.reload.balance.to_f).to eq(400.0)
        expect(to_account.reload.balance.to_f).to eq(400.0)
      end
    end

    context 'when there are insufficient funds' do
      let(:invalid_params) do
        {
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: 1000
        }
      end

      it 'returns an error' do
        expect do
          post '/transfers', params: invalid_params, headers: headers
        end.to change(Transfer, :count).by(1)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Insufficient funds')

        expect(from_account.reload.balance).to eq(500.0)
        expect(to_account.reload.balance).to eq(300.0)

        last_transfer = Transfer.last
        expect(last_transfer.failed?).to be true
      end
    end

    context 'when the from_account does not belong to the user' do
      let(:other_user) { create(:user) }
      let!(:other_account) { create(:account, user: other_user, balance: 500) }

      let(:invalid_params) do
        {
          from_account_id: other_account.id,
          to_account_id: to_account.id,
          amount: 100
        }
      end

      it 'returns an error' do
        expect do
          post '/transfers', params: invalid_params, headers: headers
        end.not_to change(Transfer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Sender account not found')
      end
    end

    context 'when the to_account does not exist' do
      let(:invalid_params) do
        {
          from_account_id: from_account.id,
          to_account_id: 0,
          amount: 100
        }
      end

      it 'returns an error' do
        expect do
          post '/transfers', params: invalid_params, headers: headers
        end.not_to change(Transfer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Recipient account not found')
      end
    end

    context 'when the amount is zero or negative' do
      let(:invalid_params) do
        {
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: 0
        }
      end

      it 'returns an error' do
        expect do
          post '/transfers', params: invalid_params, headers: headers
        end.not_to change(Transfer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Amount must be greater than zero')
      end
    end

    context 'without authentication' do
      let(:valid_params) do
        {
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: 100
        }
      end

      it 'returns unauthorized' do
        post '/transfers', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def json_response
    response.parsed_body
  end
end
