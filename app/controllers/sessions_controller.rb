require "jwt"

class SessionsController < ApplicationController
  def new
  end

  def signup
  end

  def create
    auth_header = request.headers["Authorization"]
    return head :unauthorized unless auth_header&.start_with?("Bearer ")

    token = auth_header.delete_prefix("Bearer ").strip
    payload = JWT.decode(token, nil, false).first
    user_id = payload["sub"]

    return head :unauthorized if user_id.blank?

    session[:clerk_user_id] = user_id
    head :ok
  rescue => e
    Rails.logger.warn("Session exchange failed: #{e.class}: #{e.message}")
    head :unauthorized
  end

  def destroy
    session.delete(:clerk_user_id)
    head :ok
  end
end
