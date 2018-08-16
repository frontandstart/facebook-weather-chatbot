class UsersController < ApplicationController
  # ENV['FACEBOOK_CONFIRMATION_MARKER']
  # ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] api kqye to make an API calls
  before_action :check_fb_marker, only: :facebook_messenger
  #skip_before_action :verify_authenticity_token, only: :facebook_messenger

  def facebook_messenger
    facebook_id = params[:entry][0][:messaging][0][:sender][:id]
    user = User.find_or_create_by(facebook_id: facebook_id)
    logger.debug "params[:entry][0][:messaging][0] #{params[:entry][0][:messaging][0].inspect.to_h}"
    message = Message.create( body: params[:entry][0][:messaging][0] )
    message.user = user
    if message.save
      render json: 'ok', status: 200
    else
      render json: '', status: 500 
    end
  end

  def tos
  end

  def user_agreement
  end

  protected 

  def check_fb_marker
    params['hub.verify_token'].present? && params['hub.verify_token'] == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end


end

