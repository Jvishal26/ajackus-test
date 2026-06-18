module ApplicationHelper
  def clerk_js_url
    pk = ENV["CLERK_PUBLISHABLE_KEY"]
    return nil if pk.blank?

    encoded = pk.sub(/^pk_(test|live)_/, "")
    frontend_api = Base64.decode64(encoded).chomp("$")
    "https://#{frontend_api}/npm/@clerk/clerk-js@latest/dist/clerk.browser.js"
  end
end
