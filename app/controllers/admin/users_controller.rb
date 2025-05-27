# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[show update_role]

    def index
      users = User.includes(:accounts).all
      render json: users, each_serializer: Admin::UserSerializer
    end

    def show
      render json: @user, serializer: Admin::UserDetailSerializer
    end

    def update_role
      if @user.update(role: params[:role])
        render json: { message: 'Role updated successfully', user: { id: @user.id, role: @user.role } }
      else
        render_validation_error(@user.errors.full_messages)
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('User')
    end

    def render_validation_error(errors)
      render json: ErrorSerializer.serialize(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        details: errors
      ), status: :unprocessable_entity
    end

    def render_not_found(resource)
      render json: ErrorSerializer.serialize(
        message: "#{resource} not found",
        code: "#{resource.upcase}_NOT_FOUND"
      ), status: :not_found
    end
  end
end
