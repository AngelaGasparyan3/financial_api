# frozen_string_literal: true

class TransfersController < ApplicationController
  before_action :authenticate_user

  def index
    transfers = if current_user.admin?
                  Transfer.includes(:from_account, :to_account).order(created_at: :desc)
                else
                  current_user.transfers.includes(:from_account, :to_account).order(created_at: :desc)
                end

    render json: transfers, each_serializer: TransferSerializer
  end

  def show
    transfer = Transfer
               .joins(:from_account)
               .where(from_account: { user_id: current_user.id })
               .or(Transfer.joins(:to_account).where(to_account: { user_id: current_user.id }))
               .find(params[:id])

    render json: transfer, serializer: TransferSerializer
  end

  def create
    from_account = current_user.accounts.find_by(id: params[:from_account_id])
    raise TransferService::TransferError.new('Source account not found', :not_found) unless from_account

    to_account = Account.find_by(id: params[:to_account_id])
    raise TransferService::TransferError.new('Destination account not found', :not_found) unless to_account

    amount = params[:amount].to_f

    transfer = TransferService.new(from_account, to_account, amount).call!

    render json: transfer, serializer: TransferSerializer, status: :created
  end
end
