# frozen_string_literal: true

class RemoveBalanceFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :balance, :decimal
  end
end
