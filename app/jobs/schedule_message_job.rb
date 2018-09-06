class ScheduleMessageJob < ApplicationJob
  queue_as :default

  def perform(user_id)    
    User.find(user_id).weather_report_response!
  end
end