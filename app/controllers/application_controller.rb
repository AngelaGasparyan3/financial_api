class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  rescue_from JWT::DecodeError, with: :invalid_token
  rescue_from JWT::ExpiredSignature, with: :expired_token

  protected

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    raise JWT::DecodeError, 'Missing token' unless token

    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id])
    raise JWT::DecodeError, 'User Not Found' unless @current_user
  end

  private

  def invalid_token
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def expired_token
    render json: { error: 'Token has expired' }, status: :unauthorized
  end
end
