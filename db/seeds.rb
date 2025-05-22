# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# Example seeds for users, accounts, and transfers

User.create!(email: 'admin@example.com', password: 'password', role: :admin)

user1 = User.create!(email: 'alice@example.com', password: 'password')
user2 = User.create!(email: 'bob@example.com', password: 'password')

account1 = user1.accounts.create!(number: SecureRandom.uuid, name: 'Alice Checking', balance: 500)
account2 = user2.accounts.create!(number: SecureRandom.uuid, name: 'Bob Checking', balance: 300)

Transfer.create!(from_account: account1, to_account: account2, amount: 50, status: 'completed')
