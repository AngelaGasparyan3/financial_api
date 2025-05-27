# frozen_string_literal: true

module Admin
  class UserDetailSerializer < ActiveModel::Serializer
    attributes :id, :email, :role, :created_at

    has_many :accounts, serializer: AccountSerializer

    def created_at
      object.created_at.iso8601
    end
  end
end
