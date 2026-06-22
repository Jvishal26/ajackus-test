module Test
  class SessionsController < ApplicationController
    def create
      cookies["_clerk_test_user"] = { value: params[:user_id], httponly: true }
      head :ok
    end

    def destroy
      cookies.delete("_clerk_test_user")
      head :ok
    end
  end
end
