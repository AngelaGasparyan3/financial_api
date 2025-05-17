class UpdateBalanceService
  def initialize(user, balance)
    @user = user
    @balance = balance
  end

  def call
    if @user.update balance: @balance
      { success: true, user: @user }
    else
      { success: false, error: 'Failed to Update balance' }
    end
  end
end
