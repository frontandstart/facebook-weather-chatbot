class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  # ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] api kqye to make an API calls
  before_action :check_fb_marker, only: :facebook_messenger
  before_action :set_sender, only: :facebook_messenger
  
  def facebook_messenger
    message = Message.create(
      user: @sender,
      body: request.params[:entry][0][:messaging][0]
    )
    if message.save
      render json: 'ok', status: 200
    else
      render json: '', status: 100 
    end
  end

  def tos
  end

  def user_agreement
  end

  protected 

  def set_sender
    @sender = User.find_or_create_by(facebook_id: params[:entry][0][:messaging][0][:sender][:id]) 
  end

  def check_fb_marker
    params['hub.verify_token'].present? && params['hub.verify_token'] == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end

end

