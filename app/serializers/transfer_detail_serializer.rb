# frozen_string_literal: true

class TransferDetailSerializer < ActiveModel::Serializer
  attributes :id, :from_account_id, :to_account_id, :amount, :status, :created_at

  def amount
    object.amount.to_f
  end

  def created_at
    object.created_at.iso8601
  end
end
