class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  # ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] api kqye to make an API calls
  before_action :check_fb_marker, only: :facebook_messenger

  def facebook_messenger
    messaging_body = params[:entry][0][:messaging][0]
    facebook_id = messaging_body[:sender][:id]
    user = User.find_or_create_by(facebook_id: facebook_id)
    Rails.logger.debug "messaging_body: #{messaging_body}"
    message = Message.create(
      body: messaging_body
    )
    user.messages << message
    user.save
    render json: 'ok', status: 200
  end

  protected 

  def check_fb_marker
    params['hub.verify_token'].present? && params['hub.verify_token'] == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end

end
