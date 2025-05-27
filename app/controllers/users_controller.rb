# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: %i[create login]
  before_action :require_owner_or_admin, only: [:show]

  def show
    user = User.find(params[:id])
    render json: user, serializer: UserSerializer, scope: current_user
  end

  def create
    result = CreateUserService.new(user_params).call
    return render_validation_error(result[:errors]) unless result[:success]

    result[:user].accounts.create!(number: SecureRandom.uuid, name: 'Main Account', balance: 0.0)
    render json: { message: 'User created', user: result[:user].slice(:id, :email) }, status: :created
  end

  def render_validation_error(errors)
    render json: ErrorSerializer.serialize(
      code: 'VALIDATION_FAILED',
      message: errors.join(', '),
      status: 'error'
    ), status: :unprocessable_entity
  end

  def login
    result = AuthenticateUserService.new(params[:email], params[:password]).call

    if result[:success]
      render json: { token: result[:token] }, status: :ok
    else
      render json: ErrorSerializer.serialize(
        code: 'AUTHENTICATION_FAILED',
        message: result[:error]
      ), status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
