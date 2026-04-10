module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    token = extract_token
    return render_unauthorized("Missing token") if token.nil?

    payload = JwtService.decode(token)
    @current_user = User.find_by(id: payload[:user_id])
    return render_unauthorized("User not found") unless @current_user

    if payload[:token_version].to_i != @current_user.token_version
      render_unauthorized("Token has been revoked")
    end
  rescue JWT::ExpiredSignature
    render_unauthorized("Token has expired")
  rescue JWT::DecodeError
    render_unauthorized("Invalid token")
  end

  def current_user
    @current_user
  end

  def extract_token
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    header.split(" ").last
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end
end
