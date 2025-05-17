require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :authenticate_user

    def index
      render json: { message: 'Authenticated' }
    end
  end

  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe 'Authentication' do
    context 'with valid token' do
      it 'authenticates successfully' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Authenticated')
      end
    end

    context 'with missing token' do
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid token')
      end
    end

    context 'with expired token' do
      it 'returns unauthorized with expired message' do
        expired_token = JsonWebToken.encode({ user_id: user.id }, 1.minute.ago)
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Token has expired')
      end
    end
  end
end
