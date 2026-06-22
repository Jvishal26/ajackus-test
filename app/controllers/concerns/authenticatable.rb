module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id, :signed_in?
  end

  private

  def current_user_id
    clerk_proxy&.user_id
  end

  def signed_in?
    clerk_proxy&.user? || false
  end

  def require_authentication
    redirect_to sign_in_path, alert: "Sign in to continue" unless signed_in?
  end

  def clerk_proxy
    request.env["clerk"]
  end
end
