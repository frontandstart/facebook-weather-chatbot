class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  belongs_to :user
  field :body, type: Hash
  field :category, type: String
  field :answered, type: Boolean
  after_create :make_response

  CATEGORIES = %w[get_started
                  weather_report
                  edit_location
                  location
                  subscribe_weather
                  unsubscribe_weather
                  test
                  not_found]

  def make_response
    AnswerJob.perform_later(self)
  end

  def location_response
    coordinates = body['message']['attachments'][0]['payload']['coordinates']
    user.update_location(coordinates['lat'], coordinates['long'])
  end

  def get_started_response
    # this is handle in User after_create decorator
  end
  
  def weather_report_response
    user.weather_report_response!
  end

  def edit_location_response
    SendFbMessageJob.perform_later(
      user.facebook_id,
      {
        text: I18n.t('bot.edit_location'),
        quick_replies: [{ 'content_type': 'location' }]
      }
    )
  end

  def subscribe_weather_response
    SendFbMessageJob.perform_later(
      user.facebook_id,
      { text: I18n.t('bot.subscription_successfully', time: 24.hours.from_now) }
    )
    user.subscribe_weather_report!
  end

  def unsubscribe_weather_response
    SendFbMessageJob.perform_later(
      user.facebook_id,
      { text: I18n.t('bot.unsubscription_successfull') }
    )
    user.unsubscribe_weather_report!
  end

  def test_response
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      { text: 'test_response' }
    )
  end

  def not_found_response
    Rails.logger.debug "Type of message, not found: #{self.inspect}"
  end

end