class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  def facebook_messenger
    render status: 200
  end
end
