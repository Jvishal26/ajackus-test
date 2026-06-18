module Test
  class SessionsController < ApplicationController
    def create
      cookies[ClerkTestMiddleware::COOKIE_NAME] = {
        value: params[:user_id],
        path: "/",
      }
      redirect_to root_path
    end

    def destroy
      cookies.delete(ClerkTestMiddleware::COOKIE_NAME, path: "/")
      redirect_to root_path
    end
  end
end
