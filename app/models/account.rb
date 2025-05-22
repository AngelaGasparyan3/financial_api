# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user

  has_many :outgoing_transfers,
           class_name: 'Transfer',
           foreign_key: 'from_account_id',
           inverse_of: :from_account,
           dependent: :restrict_with_error

  has_many :incoming_transfers,
           class_name: 'Transfer',
           foreign_key: 'to_account_id',
           inverse_of: :to_account,
           dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: true
  validates :name, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def sufficient_funds?(amount)
    balance.to_f >= amount.to_f
  end
end
