class ScheduleMessageJob < ApplicationJob
  queue_as :default

  def perform(user_id, interval)
    # interval - in hours
    user = User.find_by(user_id: user_id)
    if user && user.daily_weather_report?
      Message.weather_report_response(user)
      user.scheduled_weather_report(interval)
    end
  end
end
