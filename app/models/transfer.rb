# frozen_string_literal: true

class Transfer < ApplicationRecord
  belongs_to :from_account, class_name: 'Account', inverse_of: :outgoing_transfers
  belongs_to :to_account, class_name: 'Account', inverse_of: :incoming_transfers

  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[created pending completed failed] }
  validate :accounts_cannot_be_the_same
  validate :accounts_must_be_present

  enum :status, {
    created: 'created',
    pending: 'pending',
    completed: 'completed',
    failed: 'failed'
  }

  private

  def accounts_cannot_be_the_same
    return unless from_account_id.present? && from_account_id == to_account_id

    errors.add(:to_account_id, "can't be the same as from_account_id")
  end

  def accounts_must_be_present
    errors.add(:from_account, 'must exist') if from_account.nil?

    return unless to_account.nil?

    errors.add(:to_account, 'must exist')
  end
end
