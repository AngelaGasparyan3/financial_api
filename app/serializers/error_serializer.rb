# frozen_string_literal: true

class ErrorSerializer
  def self.serialize(message:, status: 'error', code: nil, details: nil)
    error_hash = {
      status: status,
      message: message
    }
    error_hash[:code] = code if code
    error_hash[:details] = details if details

    error_hash
  end
end
