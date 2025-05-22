# frozen_string_literal: true

class TransfersController < ApplicationController
  before_action :authenticate_user

  def index
    transfers =
      if @current_user.admin?
        Transfer.includes(:from_account, :to_account).order(created_at: :desc)
      else
        @current_user.transfers.includes(:from_account, :to_account).order(created_at: :desc)
      end

    render json: {
      transfers: transfers.map do |t|
        {
          id: t.id,
          amount: t.amount.to_s,
          status: t.status,
          from_account: {
            id: t.from_account.id,
            number: t.from_account.number
          },
          to_account: {
            id: t.to_account.id,
            number: t.to_account.number
          },
          created_at: t.created_at
        }
      end
    }
  end

  def show
    transfer = Transfer.joins(:from_account)
                       .where(from_account: { user_id: @current_user.id })
                       .or(Transfer.joins(:to_account)
                              .where(to_account: { user_id: @current_user.id }))
                       .find_by(id: params[:id])

    if transfer
      render json: {
        id: transfer.id,
        from_account_id: transfer.from_account_id,
        to_account_id: transfer.to_account_id,
        amount: transfer.amount,
        status: transfer.status,
        created_at: transfer.created_at
      }
    else
      render json: { error: 'Transfer not found or unauthorized' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Transfer not found' }, status: :not_found
  end

  def create
    from_account = @current_user.accounts.find_by(id: params[:from_account_id])
    to_account = Account.find_by(id: params[:to_account_id])
    amount = params[:amount].to_f

    service = TransferService.new(from_account, to_account, amount)
    result = service.call

    if result[:success]
      render json: {
        message: 'Transfer created. Processing will begin shortly.',
        transfer: {
          id: result[:transfer].id,
          from_account_id: result[:transfer].from_account_id,
          to_account_id: result[:transfer].to_account_id,
          amount: result[:transfer].amount,
          status: result[:transfer].status
        }
      }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
