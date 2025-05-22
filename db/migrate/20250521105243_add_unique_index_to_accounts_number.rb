# frozen_string_literal: true

class AddUniqueIndexToAccountsNumber < ActiveRecord::Migration[7.0]
  def change
    add_index :accounts, :number, unique: true
  end
end
