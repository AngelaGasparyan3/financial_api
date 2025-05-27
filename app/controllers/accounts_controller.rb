# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_user
  before_action :set_account, only: %i[show update_balance]

  def show
    render json: AccountSerializer.new(@account).serializable_hash
  end

  def update_balance
    result = UpdateBalanceService.new(@account, balance_params[:balance]).call

    raise UpdateBalanceService::UpdateError, result[:error] unless result[:success]

    render json: {
      message: 'Balance updated',
      account: AccountSerializer.new(result[:account]).serializable_hash
    }, status: :ok
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def balance_params
    params.require(:account).permit(:balance)
  end
end
