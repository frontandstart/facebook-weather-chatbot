class Message
  include Mongoid::Document
  embedded_in :user
  field :body, type: Hash

  after_create :check_message_type

  def check_message_type
    %w[weather_report
      edit_location
      location_message
      subscribe_weather_report
      unsubscribe_weather_report
      parse_message].each do |action_name|
      if self.send("#{action_name}?")
        self.send(action_name) and return
      end
    end
  end

  def weather_report
    SendFbMessageJob.perform_later( user.facebook_id, { text: I18n.t('bot.have_no_coordinated')} ) and return if user.lat.blank? || user.long.blank?

    temperature = user.temperature_need_to_updated? ? user.weather_from_api : user.current_temperature
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

  def postback
    body['postback']
  end

  %w[weather_report
    edit_location
    subscribe_weather_report
    unsubscribe_weather_report].each do |name|
    define_method("#{name}?".to_sym) do
      postback['payload'] == name if postback
    end
  end

  def plain_text?
    body['message'] && body['message']['text']
  end

  def location_message?
    body['message'] && body['message']['attachments'] && body['message']['attachments'][0]['type'] == 'location'
  end
   
  def plain_text
    msg = body['message']['text'].delete(' ').downcase 
    weather_report and return if %w(weatherreport wetherreport).include? msg
    edit_location and return if msg == 'editlocation'
  end

end