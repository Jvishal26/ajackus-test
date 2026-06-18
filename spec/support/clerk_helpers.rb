module ClerkHelpers
  def sign_in_as(user_id)
    page.driver.post(test_sign_in_path, user_id: user_id)
  end

  def sign_out_test_session
    page.driver.delete(test_sign_out_path)
  end
end

RSpec.configure do |config|
  config.include ClerkHelpers, type: :system
  config.include Rails.application.routes.url_helpers, type: :system
end
