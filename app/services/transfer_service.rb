class TransferService
  def initialize(sender, recipient, amount)
    @sender = sender
    @recipient = recipient
    @amount = amount.to_f
  end

  def call
    ActiveRecord::Base.transaction do
      raise "Insufficient funds..." unless @sender.sufficient_funds?(@amount)

      @sender.update! balance: @sender.balance - @amount
      @recipient.update! balance: @recipient.balance + @amount
    end
  end
end
