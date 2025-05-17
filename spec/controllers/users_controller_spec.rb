require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user, balance: 100.0) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  before { request.headers['Authorization'] = "Bearer #{token}" }

  describe 'GET #show' do
    it 'returns user balance' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['balance'].to_f).to eq(user.balance)
    end
  end

  describe 'POST #create' do
    it 'creates a user successfully' do
      post :create, params: { user: { email: 'test@example.com', password: 'password' } }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['message']).to eq('User created')
    end

    it 'fails to create a user with invalid data' do
      post :create, params: { user: { email: '', password: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end
  end

  describe 'POST #login' do
    it 'authenticates user successfully' do
      user = create(:user, email: 'test@example.com', password: 'password')
      post :login, params: { email: 'test@example.com', password: 'password' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['token']).to be_present
    end

    it 'fails with invalid credentials' do
      post :login, params: { email: 'wrong@example.com', password: 'wrong' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid credentials')
    end
  end
end
