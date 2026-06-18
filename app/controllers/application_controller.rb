class ApplicationController < ActionController::Base
  include Authenticatable

  allow_browser versions: :modern
  stale_when_importmap_changes
end
