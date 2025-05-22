# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    def index
      users = User.includes(:accounts).all
      render json: {
        users: users.map do |user|
          {
            id: user.id,
            email: user.email,
            role: user.role,
            accounts_count: user.accounts.count,
            total_balance: user.accounts.sum(:balance),
            created_at: user.created_at
          }
        end
      }
    end

    def show
      user = User.find(params[:id])
      render json: {
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          created_at: user.created_at,
          accounts: user.accounts.map do |account|
            {
              id: account.id,
              number: account.number,
              name: account.name,
              balance: account.balance
            }
          end
        }
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end

    def update_role
      user = User.find(params[:id])

      if user.update(role: params[:role])
        render json: { message: 'Role updated successfully', user: { id: user.id, role: user.role } }
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end
  end
end
