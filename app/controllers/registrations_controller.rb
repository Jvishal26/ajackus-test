class RegistrationsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end
end
