class User
  include Mongoid::Document
  field :facebook_id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :profile_pic, type: String

  embeds_many :messages, cascade_callbacks: true

  after_create :get_data_from_facebook

  def get_data_from_facebook
    #GetUserInfoFromFbJob.perform_later(facebook_id)
    #user = User.find_by(facebook_id: facebook_id)
    user = self
    response = JSON.parse HTTParty.get( user.get_fb_info_path, format: :plain), symbolize_names: true
    user.update(first_name: response.first_name , last_name: response.last_name, profile_pic: response.profile_pic)
    
    HTTParty.post( user.send_messsage_to_user_path,
      body: {
        recipient: {
          id: facebook_id
        },
        message: 
        "Hello #{user.users_name}\n
        I'm a weather bot, please share your location with me"
      
      }
    )

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
