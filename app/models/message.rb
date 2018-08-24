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
    # this is handle in User after_create decorator
  end
  
  def weather_report_response
    if user.location_blank?
      SendFbMessageJob.perform_later( user.facebook_id, { text: I18n.t('bot.have_no_coordinated')} ) and return
    end
    temperature = user.need_update_temperature? ? weather_from_api : temperature

  end

  def edit_location_response
  end

  def subscribe_weather_report_response
  end

  def test_response
  end

end

