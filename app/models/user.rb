class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :facebook_id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :profile_pic, type: String
  field :long, type: String
  field :lat, type: String
  field :daily_weather_report, type: Boolean

  field :temperature, type: Float
  field :temperature_update_at, type: DateTime
  field :location_name, type: String

  embeds_many :messages

  after_create GetUserInfoFromFbJob.perform_later(facebook_id)
  after_update :get_weather_from_api, if: :temperature_need_to_update?

  def full_name
    "#{first_name} #{last_name}"
  end

  def update_location(coordinates)
    # coordinates is hash with lat and long keys
    user.update(
      lat: coordinates['lat'],
      long: coordinates['long']
    )
  end

  def edit_location
    SendFbMessageJob.perform_later(
      user.facebook_id, 
      {
        text: I18n.t('bot.edit_location'),
        quick_replies: [{ "content_type": "location" }]
      }
    )
  end

  def subscribe_weather_report!
    update(daily_weather_report: true)
  end

  def unsubscribe_weather_report!
    update(daily_weather_report: false)
  end
    
  def temperature_need_to_update?
    location_present? && temperature_expired_or_blank? || location_changed?
  end

  def location_changed?
    lat_changed? || long_changed?
  end

  def location_blank?
    lat.blank? || long.blank?
  end

  def location_present?
    !location_blank?
  end

  def temperature_expired_or_blank?
    temperature.blank? || temperature_update_at < Time.now - 10.minutes
  end

  def set_temperature(t)
    self.update(
      temperature: t,
      temperature_update_at: Time.now
    )    
  end


  def weather_report!
    SendFbMessageJob.perform_later( user.facebook_id, { text: I18n.t('bot.have_no_coordinated')} ) and return if user.
    temperature = user.temperature_need_to_update? ? user.weather_from_api : user.temperature
    SendFbMessageJob.perform_later(
      user.facebook_id,
      { 
        text: I18n.t( 'bot.weather_report', location_name: user.location_name, temparture: temperature.to_s,  ) 
      }
    )
  end


end
