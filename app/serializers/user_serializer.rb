# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :created_at

  attribute :balance, if: :show_balance?
  attribute :accounts_count, if: :show_admin_details?
  attribute :total_balance, if: :show_admin_details?

  has_many :accounts, serializer: AccountSerializer, if: :show_accounts?

  def balance
    object.accounts.sum(:balance).to_f
  end

  def accounts_count
    object.accounts.count
  end

  def total_balance
    object.accounts.sum(:balance).to_f
  end

  def show_balance?
    scope&.id == object.id || scope&.admin?
  end

  def created_at
    object.created_at.iso8601
  end

  def show_admin_details?
    scope&.admin?
  end

  def show_accounts?
    @instance_options[:include_accounts] == true
  end
end
