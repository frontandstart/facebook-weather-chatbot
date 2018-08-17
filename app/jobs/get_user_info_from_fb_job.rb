class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(facebook_id)
    user = User.find_by(facebook_id: facebook_id)
    response = JSON.parse HTTParty.get( user.get_fb_info_path, body: {} ).body
    user.update(
      first_name: response[:first_name],
      last_name: response[:last_name],
      profile_pic: response[:profile_pic]
    )
    #to be sure tahat we have data in DB of we can check after_update if first_name was blank in Rail dirty methods 
    user.reload
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: I18n.t('bot.greeting_html', username: user.full_name),
        quick_replies: [{ "content_type": "location" }]
      }
    )
  end
end

