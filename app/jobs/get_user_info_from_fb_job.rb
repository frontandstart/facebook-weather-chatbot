class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(facebook_id)
    user = User.find_by(facebook_id: facebook_id)

    response = JSON.parse HTTParty.get( user.get_fb_info_path, format: :plain), symbolize_names: true
    user.update(first_name: response.first_name , last_name: response.last_name, profile_pic: response.profile_pic)
    
    HTTParty.post( user.send_messsage_to_user_path,
      body: {
        recipient: {
          id: facebook_id
        },
        message: 
        "Hello #{user.full_name}\n
        Are you ok?"
      
      }
    )
  end
end
