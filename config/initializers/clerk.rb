if defined?(Clerk)
  Clerk.configure do |config|
    config.excluded_routes = ["/auth/session", "/sign-out"]
  end
end
