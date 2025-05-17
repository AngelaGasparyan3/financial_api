class UsersController < ApplicationController
  before_action :authenticate_user, except: [:create, :login]


  def create
    service = CreateUserService.new user_params
    result = service.call

    if result[:success]
      render json: { message: 'User created', user: result[:user] }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def login
    service = AuthenticateUserService.new params[:email], params[:password]
    result = service.call

    if result[:success]
      render json: { token: result[:token] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  def show
    render json: { balance: @current_user.balance.to_f }
  end

  def update_balance
    service = UpdateBalanceService.new @current_user, params[:balance]
    result = service.call

    if result[:success]
      render json: { message: 'Balance updated', user: result[:user] }
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def transfer
    recipient = User.find_by(id: params[:recipient_id])
    return render json: { error: 'Recipient not found' }, status: :not_found unless recipient

    unless @current_user.sufficient_funds?(params[:amount].to_f)
      return render json: { error: "Insufficient funds. Available: #{@current_user.balance}, Requested: #{params[:amount]}" }, status: :unprocessable_entity
    end

    begin
      TransferService.new(@current_user, recipient, params[:amount].to_f).call
      render json: { message: 'Transfer successful', sender_balance: @current_user.balance, recipient_balance: recipient.balance }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
