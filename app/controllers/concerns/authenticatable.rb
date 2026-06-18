module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id, :user_signed_in?
  end

  def current_user_id
    @current_user_id ||= ClerkAuthService.authenticate(request)
  end

  def user_signed_in?
    current_user_id.present?
  end

  def require_authentication
    return if user_signed_in?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Please sign in to vote" }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end
end
