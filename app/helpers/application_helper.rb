module ApplicationHelper
  def clerk_js_url
    pk = ENV.fetch("CLERK_PUBLISHABLE_KEY", "")
    return "" if pk.blank?
    frontend_api = Base64.decode64(pk.sub(/^pk_(test|live)_/, "")).chomp("$")
    "https://#{frontend_api}/npm/@clerk/clerk-js@latest/dist/clerk.browser.js"
  end
end
