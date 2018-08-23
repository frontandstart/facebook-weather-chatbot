class WeatherRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    response = HTTParty.get(
      ENV['WEATHER_API_PATH'],
      query: {
        lat: user.lat,
        lon: user.long
        'APPID': ENV['WEATHER_KEY'] 
      },
      headers: {'Content-Type' => 'application/json'}
    )
    temperature = (response['list'].last['main']['temp'].to_f - 273.15 ).round(2)
    user.set_temperature(temperature)
  end
end
