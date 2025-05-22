# frozen_string_literal: true

class TransferService
  def initialize(from_account, to_account, amount)
    @from_account = from_account
    @to_account = to_account
    @amount = amount.to_f
  end

  def call
    validation_result = validate_transfer
    return validation_result unless validation_result[:success]

    transfer = create_transfer_record
    return { success: false, error: transfer.errors.full_messages.join(', ') } unless transfer.persisted?

    process_transfer(transfer)
  rescue StandardError => e
    Rails.logger.error "Transfer failed: #{e.message}"
    { success: false, error: 'Transfer failed due to system error' }
  end

  private

  def validate_transfer
    return { success: false, error: 'Sender account not found' } unless @from_account
    return { success: false, error: 'Recipient account not found' } unless @to_account
    return { success: false, error: 'Amount must be greater than zero' } if @amount <= 0
    return { success: false, error: 'Cannot transfer to the same account' } if @from_account.id == @to_account.id

    { success: true }
  end

  def create_transfer_record
    Transfer.create(
      from_account: @from_account,
      to_account: @to_account,
      amount: @amount,
      status: 'created'
    )
  end

  def process_transfer(transfer)
    sufficient_funds = check_sufficient_funds

    unless sufficient_funds
      transfer.update!(status: 'failed')
      return { success: false, error: 'Insufficient funds', transfer: transfer }
    end

    execute_transfer_transaction(transfer)
  end

  def check_sufficient_funds
    ActiveRecord::Base.transaction do
      locked_from_account = Account.lock.find(@from_account.id)
      locked_from_account.sufficient_funds?(@amount)
    end
  end

  def execute_transfer_transaction(transfer)
    ActiveRecord::Base.transaction do
      locked_from_account = Account.lock.find(@from_account.id)
      locked_to_account = Account.lock.find(@to_account.id)

      unless locked_from_account.sufficient_funds?(@amount)
        transfer.update!(status: 'failed')
        raise InsufficientFundsError, 'Insufficient funds'
      end

      locked_from_account.update!(balance: locked_from_account.balance - @amount)
      locked_to_account.update!(balance: locked_to_account.balance + @amount)

      { success: true, transfer: transfer }
    end
  rescue InsufficientFundsError => e
    { success: false, error: e.message, transfer: transfer }
  end

  class InsufficientFundsError < StandardError; end
end
