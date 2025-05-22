# frozen_string_literal: true

class ProcessTransferJob < ApplicationJob
  queue_as :default

  def perform(transfer_id)
    transfer = Transfer.find_by(id: transfer_id)
    return unless transfer

    transfer.pending!

    from_account = transfer.from_account
    to_account = transfer.to_account
    amount = transfer.amount

    Transfer.transaction do
      from_account.lock!
      to_account.lock!

      if from_account.sufficient_funds?(amount)
        from_account.update!(balance: from_account.balance - amount)
        to_account.update!(balance: to_account.balance + amount)
        transfer.completed!

      else
        transfer.failed!
      end
    end
  rescue StandardError => e
    transfer.failed! if transfer&.persisted?
    Rails.logger.error("Transfer processing failed: #{e.message}")
  end
end
