# frozen_string_literal: true

class CreateUserService
  def initialize(params)
    @params = params
    @user = User.new params
  end

  def call
    if @user.save
      { success: true, user: @user }
    else
      { success: false, errors: @user.errors.full_messages }
    end
  end
end
