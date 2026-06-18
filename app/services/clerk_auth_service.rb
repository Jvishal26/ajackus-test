class ClerkAuthService
  def self.authenticate(request)
    new(request).call
  end

  def initialize(request)
    @request = request
  end

  def call
    token = extract_token
    return nil if token.blank?

    verify_token(token)
  rescue JWT::DecodeError => e
    Rails.logger.warn("Clerk token verification failed: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("Unexpected auth error: #{e.class} - #{e.message}")
    nil
  end

  private

  attr_reader :request

  def extract_token
    request.cookies["__session"] ||
      request.headers["Authorization"]&.delete_prefix("Bearer ")
  end

  def verify_token(token)
    sdk = Clerk::SDK.new
    claims = sdk.verify_token(token)
    claims&.fetch("sub", nil)
  end
end
