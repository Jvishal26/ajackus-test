class ClerkTestMiddleware
  COOKIE_NAME = "_test_clerk_user_id"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    user_id = request.cookies[COOKIE_NAME]

    env["clerk"] = if user_id.present?
      Clerk::Proxy.new(session_claims: { "sub" => user_id })
    else
      Clerk::Proxy.new
    end

    @app.call(env)
  end
end
