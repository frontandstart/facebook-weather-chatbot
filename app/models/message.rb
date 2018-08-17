class Message
  include Mongoid::Document
  embedded_in :user
  field :body, type: Hash # we just store params[:entry][:messaging] json

  after_create :response_to_user_or_update_data
  
  def response_to_user_or_update_data
    if location_message?
      coordinates = body['attachments'][0]['payload']['coordinates']
      user.update(
        lat: coordinates['lat'],
        long: coordinates['long']
      )
      return
    end

    if weather_report?

    end

    if weather_subscribtion_report?

    end
  end


  def weather_report?
    return false
  end

  def weather_subscribtion_report?
    return false
  end

  def location_message?
    body['message']['attachments'].present? && body['message']['attachments'][0]['type'] == 'location' ? true : false
  end


end
