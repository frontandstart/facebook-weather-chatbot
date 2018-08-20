class WeatherRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    #Rails.logger.debug "temp #{user.weather_from_api}"
  end
end
