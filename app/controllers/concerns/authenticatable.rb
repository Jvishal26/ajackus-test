module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id, :current_user, :user_signed_in?
  end

  def current_user_id
    @current_user_id ||= clerk_proxy&.user_id
  end

  def current_user
    @current_user ||= clerk_proxy&.user
  rescue => e
    Rails.logger.warn("Could not fetch Clerk user: #{e.message}")
    nil
  end

  def user_signed_in?
    clerk_proxy&.user? || false
  end

  def require_authentication
    return if user_signed_in?

    respond_to do |format|
      format.html { redirect_to sign_in_path, alert: "Please sign in to continue" }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end

  private

  def clerk_proxy
    request.env["clerk"]
  end
end
