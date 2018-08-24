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
  after_update WeatherRequestJob.perform_later(self, false), if: :location_changed?

  def full_name
    "#{first_name} #{last_name}"
  end

  def subscribe_weather_report!
    update(daily_weather_report: true)
  end

  def unsubscribe_weather_report!
    update(daily_weather_report: false)
  end
    
  def need_update_temperature?
    location_present? && ( temperature_expired_or_blank? || location_changed? )
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
    # Do not need to update weather if request came from same location less than 5 min
    temperature.blank? || temperature_update_at < Time.now - 5.minutes
  end

  def update_temperature(t)
    update(
      temperature: t,
      temperature_update_at: Time.now)   
  end

  def update_location(coordinates)
    # coordinates is hash with lat and long keys
    update(
      lat: coordinates['lat'],
      long: coordinates['long'])
  end

end
