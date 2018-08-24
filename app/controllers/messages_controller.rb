class MessagesController < ApplicationController
  include MessagesHelper

  before_action :set_sender_and_message_type, only: :facebook_messenger
  
  def facebook_messenger
    message = Message.new(
      user: @sender,
      body: @messaging,
      category: find_category
    )
    if message.save
      render json: { success: true }, status: 200
    else
      render json: { success: false }, status: 100
    end
  end

  def tos; end

  def user_agreement; end

  protected

  def set_sender_and_message_type
    @messaging = request.params[:entry][0][:messaging][0]
    @sender = User.find_or_create_by(facebook_id: @messaging[:sender][:id])
  end

  def find_category
    parse_body_for(postback) || parse_body_for(location) || parse_body_for(plaintext) || 'not_found'
  end

  def postback
    @messaging['postback'] && @messaging['postback']['payload']
  end

  def plaintext
    @messaging['message'] && @messaging['message']['text']
  end

  def location
    @messaging['message'] && @messaging['message']['attachments'] && @messaging['message']['attachments'][0]['type']
  end
 
  def check_fb_marker
    params.dig('hub.verify_token') == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end

end