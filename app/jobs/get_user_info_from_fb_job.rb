class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(user)
    response = JSON.parse HTTParty.get(user.fb_info_path, body: {}).body, symbolize_names: true
    user.update(
      first_name: response[:first_name],
      last_name: response[:last_name],
      profile_pic: response[:profile_pic]
    )
    SendFbMessageJob.perform_later(
      user.facebook_id,
      {
        text: I18n.t('bot.greeting_html', username: response[:first_name]),
        quick_replies: [{ 'content_type': 'location' }]
      }
    )
  end
end

