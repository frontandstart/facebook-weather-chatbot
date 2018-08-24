class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

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

  has_many :messages

  after_create :find_fb_user
  after_update :weather_request, if: :need_update_temperature? 

  def find_fb_user
    GetUserInfoFromFbJob.perform_later(self)
  end

  def weather_request
    WeatherRequestJob.perform_later(self.facebook_id, false)
  end

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

  def update_temperature(t, location)
    update(
      temperature: t,
      location_name: location,
      temperature_update_at: Time.now)   
  end

  def update_location(lat, long)
    update(
      lat: lat,
      long: long)
  end

  def update_user_info_from_fb(response)
    update(
      first_name: response['first_name'],
      last_name: response['last_name'],
      profile_pic: response['profile_pic']
    )
  end

  def fb_info_path
    "#{ENV['FB_API_PATH']}/#{facebook_id}?access_token=#{ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']}" 
  end

  def weather_message!(temp, name)
    # i did it becouse sometime DB update can be slowed than Sidekiq job taht sending sessage
    temp ||= temperature
    name ||= location_name
    SendFbMessageJob.perform_later(
      facebook_id,
      {
        text: I18n.t( 'bot.weather_report', location_name: name, temparature: temp.to_s )
      }
    )
  end


end
