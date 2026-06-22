module ClerkHelpers
  def sign_in_as(user_id)
    post "/test/sign-in", params: { user_id: user_id }
  end

  def sign_out
    delete "/test/sign-out"
  end
end

RSpec.configure do |config|
  config.include ClerkHelpers, type: :request
  config.include ClerkHelpers, type: :system
end
