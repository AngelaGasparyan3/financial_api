# frozen_string_literal: true

class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }
      t.decimal :amount, null: false
      t.string :status

      t.timestamps
    end
  end
end
