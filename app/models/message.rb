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
    user.update_location(
      body['message']['attachments'][0]['payload']['coordinates']
    )
  end

  def get_started_response
  end
  
  def weather_report_response
  end

  def edit_location_response
  end

  def subscribe_weather_report_response
  end

  def test_response
  end

end

