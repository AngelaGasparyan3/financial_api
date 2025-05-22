# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  enum :role, { regular: 0, admin: 1 }

  has_many :accounts, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def transfers
    Transfer.where('from_account_id IN (?) OR to_account_id IN (?)', accounts.ids, accounts.ids)
  end
end
