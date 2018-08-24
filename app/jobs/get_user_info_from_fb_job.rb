class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(user)
    response = JSON.parse HTTParty.get(user.fb_info_path, body: {}).body
    Rails.logger.debug "First time get user: #{response['first_name']} Data from FB: #{response.inspect}"
    SendFbMessageJob.perform_later(
      user.facebook_id,
      {
        text: I18n.t('bot.greeting_html', username: response['first_name']),
        quick_replies: [{ 'content_type': 'location' }]
      }
    )
    user.update_user_info_from_fb(response)
  end
end

