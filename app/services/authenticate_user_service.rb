# frozen_string_literal: true

class AuthenticateUserService
  # require_relative '../../lib/json_web_token'

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    user = User.find_by(email: @email)
    if user&.authenticate @password
      token = JsonWebToken.encode(user_id: user.id)
      { success: true, token: token }
    else
      { success: false, error: 'Invalid credentials' }
    end
  end
end
