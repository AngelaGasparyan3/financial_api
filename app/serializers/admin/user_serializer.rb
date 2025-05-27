# frozen_string_literal: true

module Admin
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :role, :accounts_count, :total_balance, :created_at

    def accounts_count
      object.accounts.count
    end

    def total_balance
      object.accounts.sum(:balance).to_f
    end

    def created_at
      object.created_at.iso8601
    end
  end
end
