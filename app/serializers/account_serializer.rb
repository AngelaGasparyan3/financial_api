# frozen_string_literal: true

class AccountSerializer < ActiveModel::Serializer
  attributes :id, :number, :name, :balance
  belongs_to :user, serializer: UserSerializer, if: :show_user?

  def balance
    object.balance.to_f
  end

  def show_user?
    @instance_options[:include_user] == true
  end
end
