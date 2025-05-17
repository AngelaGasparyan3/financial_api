class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true

  def sufficient_funds?(amount)
    balance >= amount
  end
end
