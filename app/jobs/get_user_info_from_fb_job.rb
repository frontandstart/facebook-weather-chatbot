class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(facebook_id)
    user = User.find_by(facebook_id: facebook_id)
    response = JSON.parse HTTParty.get( user.get_fb_info_path, format: :plain), symbolize_names: true
    user.update(first_name: response[:first_name] , last_name: response[:last_name], profile_pic: response[:profile_pic])

    SendFbMessageJob.perform_later(user.facebook_id, "Hello #{user.full_name}!")
    ShareLocationJob.wait(1.second).perform_later(user.facebook_id, "I'm a weather bot, please share your location with me")
  end
end

