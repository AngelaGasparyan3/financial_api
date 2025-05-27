# frozen_string_literal: true

class TransferSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :from_account_id, :to_account_id, :from_account, :to_account, :created_at

  def from_account
    {
      id: object.from_account.id,
      number: object.from_account.number
    }
  end

  def to_account
    {
      id: object.to_account.id,
      number: object.to_account.number
    }
  end

  def amount
    object.amount.to_f
  end
end
