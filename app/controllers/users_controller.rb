class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  def facebook_messenger
    render json: params['hub.challenge'], status: 200
  end
end
