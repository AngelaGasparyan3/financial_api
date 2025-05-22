# frozen_string_literal: true

class UpdateBalanceService
  def initialize(account, balance)
    @account = account
    @balance = balance
  end

  def call
    if @account.update(balance: @balance.to_f)
      { success: true, account: @account }
    else
      { success: false, error: 'Failed to update balance' }
    end
  end
end
