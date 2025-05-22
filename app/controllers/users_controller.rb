# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: %i[create login]
  before_action :require_owner_or_admin, only: [:show]

  def show
    user = User.find(params[:id])

    if current_user.admin?
      render json: {
        id: user.id,
        email: user.email,
        role: user.role,
        balance: user.accounts.sum(:balance),
        accounts_count: user.accounts.count,
        created_at: user.created_at
      }
    elsif user == current_user
      account = user.accounts.first
      balance = account ? account.balance : 0.0
      render json: { id: user.id, email: user.email, balance: balance }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def create
    service = CreateUserService.new(user_params)
    result = service.call

    if result[:success]
      result[:user].accounts.create!(
        number: SecureRandom.uuid,
        name: 'Main Account',
        balance: 0
      )
      render json: { message: 'User created', user: result[:user] }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def login
    service = AuthenticateUserService.new(params[:email], params[:password])
    result = service.call

    if result[:success]
      render json: { token: result[:token] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def require_owner_or_admin
    user_id = params[:id].to_i
    return if current_user.admin? || current_user.id == user_id

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
