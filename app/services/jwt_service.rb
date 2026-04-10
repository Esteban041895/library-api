module JwtService
  ALGORITHM = "HS256"

  def self.secret_key
    Rails.application.secret_key_base
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::ExpiredSignature
    raise JWT::ExpiredSignature, "Token has expired"
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, "Invalid token: #{e.message}"
  end
end
