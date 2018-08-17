class Message
  include Mongoid::Document
  embedded_in :user
  field :body, type: Hash # we just store params[:entry][:messaging] json

  after_create :response_to_user_or_update_data
  
  def response_to_user_or_update_data
    if self.location_message?
      coordinates = body[:attachments][0][:payload][:coordinates]
      self.user.update(
        lat: coordinates[:lat],
        long: coordinates[:long]
      ) and return
    end

    if self.weather_report?

    end

    if self.weather_subscribtion_report?

    end
  end


  def weather_report?
    return false
  end

  def weather_subscribtion_report?
    return false
  end

  def location_message?
    body[:attachments].present? && body[:attachments][0][:type] == 'location'
  end


end
