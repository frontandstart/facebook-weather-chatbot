class Message
  include Mongoid::Document
  embedded_in :user
  field :body, type: Hash # we just store params[:entry][:messaging] json

  after_create :weather_report, if: :weather_report?
  after_create :edit_location, if: :edit_location?
  after_create :location_message, if: :location_message?
  after_create :subscribe_weather_report, if: :subscribe_weather_report?
  after_create :unsubscribe_weather_report, if: :unsubscribe_weather_report?
  after_create :parse_message, if: :plain_text?

  def weather_report
    SendFbMessageJob.perform_later( user.facebook_id, { text: I18n.t('bot.have_no_coordinated')} ) and return if user.lat.blank? || user.long.blank?

    temperature = user.temperature_need_to_updated? ? user.get_weather_from_api : user.current_temperature
    SendFbMessageJob.perform_later(
      user.facebook_id,
      { 
        text: I18n.t( 'bot.weather_report', current_location_name: user.current_location_name, temparture: temperature.to_s,  ) 
      }
    )
  end
  
  def edit_location
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: I18n.t('bot.edit_location'),
        quick_replies: [{ "content_type": "location" }]
      }
    )
  end

  def location_message
    coordinates = body['message']['attachments'][0]['payload']['coordinates']
    user.update(
      lat: coordinates['lat'],
      long: coordinates['long']
    )
  end

  def subscribe_weather_report
    user.subscribe_weather_report!
  end

  def unsubscribe_weather_report
    user.unsubscribe_weather_report!
  end

  def location_message?
    body['message'] && body['message']['attachments'] && body['message']['attachments'][0]['type'] == 'location'
  end

  def postback
    body['postback']
  end

  def weather_report?
    postback['payload'] == 'weather_report' if postback
  end

  def edit_location?
    postback['payload'] == 'edit_location' if postback
  end

  def subscribe_weather_report?
    postback['payload'] == 'subscribe_weather_report' if postback
  end

  def unsubscribe_weather_report?
    postback['payload'] == 'unsubscribe_weather_report' if postback
  end
  
  def parse_message
    msg = body['message']['text'].delete(' ').downcase 
    weather_report and return if %w(weatherreport wetherreport).include? msg
    edit_location and return if msg == 'editlocation'
    SendFbMessageJob.perform_later(facebook_id, {text: 'test_response'}) if msg == 'test'
  end

  def plain_text?
    body['message'] && body['message']['text']
  end

end