# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_user

  rescue_from JWT::ExpiredSignature, with: :expired_token
  rescue_from JWT::DecodeError, with: :invalid_token
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  attr_reader :current_user

  private

  def authenticate_user
    header = request.headers['Authorization']
    if header.present?
      token = header.split.last
      begin
        decoded = JsonWebToken.decode(token)
        @current_user = User.find(decoded[:user_id])
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def require_admin
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end

  def require_owner_or_admin(resource_user_id = nil)
    resource_user_id ||= params[:id].to_i
    return if current_user&.admin? || current_user&.id == resource_user_id

    render json: { error: 'Unauthorized access' }, status: :forbidden
  end
end
