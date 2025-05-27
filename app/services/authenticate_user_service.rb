# frozen_string_literal: true

class AuthenticateUserService
  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    user = User.find_by(email: email)
    if user&.authenticate(password)
      { success: true, token: JsonWebToken.encode(user_id: user.id) }
    else
      { success: false, error: 'Invalid credentials' }
    end
  end

  private

  attr_reader :email, :password
end
