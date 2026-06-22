class ClerkTestMiddleware
  COOKIE_NAME = "_clerk_test_user"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    user_id = request.cookies[COOKIE_NAME]
    env["clerk"] = FakeProxy.new(user_id) if user_id.present?
    @app.call(env)
  end

  class FakeProxy
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def user?
      true
    end
  end
end
