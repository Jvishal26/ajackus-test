class SessionsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end

  def destroy
    sign_out_url = ENV.fetch("CLERK_SIGN_OUT_URL", root_url)
    redirect_to sign_out_url, allow_other_host: true
  end
end
