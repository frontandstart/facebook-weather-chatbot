class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(facebook_id)
    user = User.find_by(facebook_id: facebook_id)
    response = JSON.parse HTTParty.get( user.get_fb_info_path, plain: true ), symbolize_names: true
    user.update(
      first_name: response[:first_name],
      last_name: response[:last_name],
      profile_pic: response[:profile_pic]
    )
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: I18n.t('bot.greeting_html', username: user.full_name),
        quick_replies: [{ "content_type": "location" }]
      }
    )
  end
end

