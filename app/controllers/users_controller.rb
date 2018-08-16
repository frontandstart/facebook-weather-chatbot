class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  # ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] api kqye to make an API calls
  before_action :check_fb_marker, only: :facebook_messenger

  def facebook_messenger
    facebook_id = params['entry']['messaging']['sender']['id'].to_i
    user = User.find_or_create_by(facebook_id: facebook_id)
    message = Message.create(
      body: params[:entry][:messaging]
    )
    user.messages << message

    #render json: params['hub.challenge'], status: 200
  end

  protected 

  def check_fb_marker
    params['hub.verify_token'].present? && params['hub.verify_token'] == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end

end
