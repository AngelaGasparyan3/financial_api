# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_user

  def show
    account = @current_user.accounts.find(params[:id])
    render json: {
      id: account.id,
      number: account.number,
      name: account.name,
      balance: account.balance.to_f
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Account not found' }, status: :not_found
  end

  def update_balance
    account = @current_user.accounts.find(params[:id])
    service = UpdateBalanceService.new(account, params[:balance])
    result = service.call

    if result[:success]
      render json: {
        message: 'Balance updated',
        account: result[:account].as_json.merge(balance: result[:account].balance.to_f)
      }
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Account not found' }, status: :not_found
  end
end
