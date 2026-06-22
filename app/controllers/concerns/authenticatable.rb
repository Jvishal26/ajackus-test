module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id, :signed_in?
  end

  private

  def current_user_id
    session[:clerk_user_id] || request.env["clerk"]&.user_id
  end

  def signed_in?
    session[:clerk_user_id].present? || request.env["clerk"]&.user? || false
  end

  def require_authentication
    redirect_to sign_in_path, alert: "Sign in to continue" unless signed_in?
  end
end
