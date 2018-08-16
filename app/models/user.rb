class User
  include Mongoid::Document
  field :facebook_id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :profile_pic, type: String

  embeds_many :messages

  after_create :get_data_from_facebook

  def get_data_from_facebook
    GetUserInfoFromFbJob.perform_later(facebook_id)
  end

  def get_fb_info_path
    "#{ENV['FB_API_PATH']}/#{facebook_id}?access_token=#{ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']}" 
  end

  def send_messsage_to_user_path
    "#{ENV['FB_API_PATH']}/me/messages?access_token=#{ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

end
