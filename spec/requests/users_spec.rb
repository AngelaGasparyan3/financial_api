# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /users' do
    let(:valid_attributes) do
      { user: { email: 'test@example.com', password: 'password123' } }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          post '/users', params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it 'returns a 201 status code' do
        post '/users', params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns the created user' do
        post '/users', params: valid_attributes
        expect(json_response['user']['email']).to eq('test@example.com')
      end

      it 'creates a default account for the user' do
        post '/users', params: valid_attributes
        user = User.find_by(email: 'test@example.com')
        expect(user.accounts.count).to eq(1)
        expect(user.accounts.first.name).to eq('Main Account')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect do
          post '/users', params: { user: { email: '', password: 'password123' } }
        end.to_not change(User, :count)
      end

      it 'returns a 422 status code' do
        post '/users', params: { user: { email: '', password: 'password123' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post '/users', params: { user: { email: '', password: 'password123' } }
        expect(json_response['errors']).to include(/Email can't be blank/)
      end
    end
  end

  describe 'POST /login' do
    let!(:user) { create(:user, email: 'existing@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/login', params: { email: 'existing@example.com', password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(json_response['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post '/login', params: { email: 'existing@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid credentials')
      end
    end
  end

  describe 'GET /users/:id' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    context 'when fetching own profile' do
      it 'returns the user' do
        get "/users/#{user.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['email']).to eq(user.email)
      end
    end

    context "when fetching another user's profile" do
      it 'returns unauthorized status' do
        get "/users/#{other_user.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        get "/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def json_response
    response.parsed_body
  end
end
