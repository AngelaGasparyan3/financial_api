# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_user

  rescue_from JWT::ExpiredSignature, with: :expired_token
  rescue_from JWT::DecodeError, with: :invalid_token
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from TransferService::TransferError, with: :transfer_error
  rescue_from UpdateBalanceService::UpdateError, with: :update_failed

  attr_reader :current_user

  private

  def authenticate_user
    header = request.headers['Authorization']
    return render_error(code: 'INVALID_TOKEN', message: 'Invalid token', status: :unauthorized) if header.blank?

    token = header.split.last
    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id])
  rescue JWT::ExpiredSignature
    expired_token
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    invalid_token
  end

  def require_admin
    return if current_user&.admin?

    render_error(code: 'FORBIDDEN', message: 'Admin access required', status: :forbidden)
  end

  def require_owner_or_admin(resource_user_id = nil)
    resource_user_id ||= params[:id].to_i
    return if current_user&.admin? || current_user&.id == resource_user_id

    render_error(code: 'UNAUTHORIZED', message: 'Unauthorized access', status: :forbidden)
  end

  def record_not_found(exception)
    if exception.model == 'Account'
      message = 'Account not found'
      code = 'ACCOUNT_NOT_FOUND'
    else
      message = "#{exception.model} not found"
      code = 'NOT_FOUND'
    end

    render json: ErrorSerializer.serialize(message: message, code: code), status: :not_found
  end

  def expired_token
    render_error(code: 'TOKEN_EXPIRED', message: 'Token has expired', status: :unauthorized)
  end

  def invalid_token
    render_error(code: 'INVALID_TOKEN', message: 'Invalid token', status: :unauthorized)
  end

  def update_failed(exception)
    render json: ErrorSerializer.serialize(message: exception.message, code: 'UPDATE_FAILED'), status: :unprocessable_entity
  end

  def transfer_error(exception)
    render_error(code: 'TRANSFER_FAILED', message: exception.message, status: exception.status)
  end

  def render_error(code:, message:, status:, details: nil)
    render json: ErrorSerializer.serialize(
      message: message,
      code: code,
      details: details,
      status: 'error'
    ), status: status
  end
end
