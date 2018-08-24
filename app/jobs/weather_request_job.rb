class WeatherRequestJob < ApplicationJob
  queue_as :default

  def perform(user, need_send: false)
    response = HTTParty.get(
      ENV['WEATHER_API_PATH'],
      query: {
        lat: user.lat,
        lon: user.long,
        'APPID': ENV['WEATHER_KEY'] 
      },
      headers: { 'Content-Type' => 'application/json' }
    )
    Rails.logger.debug "Get weather for User: #{user.id}"
    Rails.logger.debug "Weather response: #{response}"
    if response['cod'] == 200 
      new_temperature = (response['main']['temp'].to_f - 273.15 ).round(2)
      user.update_temperature(new_temperature)
      if need_send
        ::Message.weather_message(user.facebook_id, user.location, new_temperature)
      end  
    end
    if response['code'] != 200
      SendFbMessageJob.perform_later(
        user.facebook_id,
        {
          text: I18n.t('bot.cant_get_weather_data')
        }
      )
    end

  end
end
