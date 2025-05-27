# frozen_string_literal: true

class TransferService
  class TransferError < StandardError
    attr_reader :status

    def initialize(message, status = :unprocessable_entity)
      super(message)
      @status = status
    end
  end

  class DuplicateTransferError < TransferError; end
  class InsufficientFundsError < TransferError; end
  class AccountNotFoundError < TransferError; end
  class InvalidAmountError < TransferError; end

  def initialize(from_account, to_account, amount)
    @from_account = from_account
    @to_account = to_account
    @amount = amount.to_f
  end

  def call!
    raise AccountNotFoundError, 'Sender account not found' unless @from_account
    raise AccountNotFoundError, 'Recipient account not found' unless @to_account
    raise InvalidAmountError, 'Amount must be greater than zero' unless @amount.positive?
    raise DuplicateTransferError, 'Duplicate transfer detected' if duplicate_transfer?

    Transfer.transaction do
      from_account_locked = Account.lock.find(@from_account.id)
      to_account_locked   = Account.lock.find(@to_account.id)

      raise InsufficientFundsError, 'Insufficient funds' if from_account_locked.balance < @amount

      from_account_locked.update!(balance: from_account_locked.balance - @amount)
      to_account_locked.update!(balance: to_account_locked.balance + @amount)

      Transfer.create!(
        from_account: from_account_locked,
        to_account: to_account_locked,
        amount: @amount,
        status: 'created'
      )
    end
  rescue InsufficientFundsError
    create_failed_transfer
    raise
  rescue ActiveRecord::RecordInvalid => e
    raise TransferError, e.message
  end

  def call
    transfer = call!
    { success: true, transfer: transfer }
  rescue DuplicateTransferError, InsufficientFundsError => e
    transfer = create_failed_transfer(e.message)
    { success: false, error: e.message, transfer: transfer }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def duplicate_transfer?
    Transfer.exists?(from_account: @from_account,
                     to_account: @to_account,
                     amount: @amount,
                     created_at: 1.minute.ago..Time.current)
  end

  def create_failed_transfer(_error_status = nil)
    return unless @from_account && @to_account

    Transfer.create(
      from_account: @from_account,
      to_account: @to_account,
      amount: @amount,
      status: 'failed'
    )
  end
end
