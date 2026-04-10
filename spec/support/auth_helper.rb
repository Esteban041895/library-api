module AuthHelper
  def auth_headers(user)
    token = JwtService.encode(user_id: user.id, token_version: user.token_version)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
