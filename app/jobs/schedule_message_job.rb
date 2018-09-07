class ScheduleMessageJob < ApplicationJob
  queue_as :default

  def perform(user)
    user.daily_weather_report_response!
  end
end