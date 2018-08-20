class UsersController < ApplicationController
  before_action :set_sender, only: :facebook_messenger

  def facebook_messenger
    message = Message.create(
      user: @sender,
      body: @messaging
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

  def set_sender
    @messaging = request.params[:entry][0][:messaging][0]
    @sender = User.find_or_create_by(facebook_id: @messaging[:sender][:id])
  end

  def check_fb_marker
    params.dig('hub.verify_token') == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end
end