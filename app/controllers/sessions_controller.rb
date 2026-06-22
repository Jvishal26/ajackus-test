class SessionsController < ApplicationController
  def new
    redirect_to root_path if signed_in?
  end

  def signup
    redirect_to root_path if signed_in?
  end

  def destroy
    redirect_to root_path
  end
end
