# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.decimal :balance, default: 0.0
      t.string :password_digest

      t.timestamps
    end
  end
end
