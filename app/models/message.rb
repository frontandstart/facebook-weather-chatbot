class Message
  include Mongoid::Document
  embedded_in :user
  field :body, type: Hash
  field :type, type: String
  field :answered, type: Boolean, default: true

  after_create AnswerJob.perform_later("#{type}_response")

  TYPES = %w[get_started
            weather_report
            edit_location
            location
            subscribe_weather_report
            unsubscribe_weather_report
            test]


  def location_response
    user.update_location(body['message']['attachments'][0]['payload']['coordinates'])
  end

  def get_started_response
    # this is handle in User after_create decorator
  end
  
  def weather_report_response
    if user.location_blank?
      SendFbMessageJob.perform_later(
        user.facebook_id,
        {
          text: I18n.t('bot.have_no_coordinated')
        }
      ) and return
    end

    if user.need_update_temperature? 
      WeatherRequestJob.perform_later(user, true)
    else
      weather_message(user.facebook_id, user.location_name, user.temperature.to_s)
    end
  end

  def edit_location_response
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: I18n.t('bot.edit_location'),
        quick_replies: [{ "content_type": "location" }]
      }
    )
  end

  def subscribe_weather_report_response
    user.subscribe_weather_report!
  end

  def unsubscribe_weather_report_response
  user.unsubscribe_weather_report!
  end

  def test_response
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: 'test_response'
      }
    )
  end


  def self.weather_message(facebook_id, location, temp)
    SendFbMessageJob.perform_later(
      facebook_id,
      {
        text: I18n.t( 'bot.weather_report', location_name: location, temparture: temp.to_s )
      }
    )  
  end


end

