class GetUserInfoFromFbJob < ApplicationJob
  queue_as :default

  def perform(user)
    response = JSON.parse HTTParty.get(
      "#{ENV['FB_API_PATH']}/#{user.facebook_id}",
      query: {
        access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']
      },
      body: {}
    ).body
    Rails.logger.debug "First time get user: #{user.id}. Data from FB: #{response.inspect}"
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