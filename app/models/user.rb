class User
  require 'sidekiq/api'
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
  field :daily_weather_report_jid, type: String

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
    unsubscribe_weather_report!
    create_schedule_report_job
  end

  def unsubscribe_weather_report!
    if daily_weather_report_jid
      job = Sidekiq::ScheduledSet.new.find_job(daily_weather_report_jid)
      job.delete
      update(daily_weather_report_jid: nil)
    end
  end

  def create_schedule_report_job
    job = ScheduleMessageJob.set(wait: 24.hours).perform_later(self)
    update(daily_weather_report_jid: job.provider_job_id)  
  end

  def daily_weather_report_response!
    create_schedule_report_job
    weather_report_response!
  end

  def weather_report_response!
    if location_blank?
      SendFbMessageJob.perform_later(
        facebook_id,
        { text: I18n.t('bot.have_no_coordinated') }
      ) && return
    end
    WeatherRequestJob.perform_later(facebook_id, true) and return if need_update_temperature?  
    weather_message!
  end
    
  def need_update_temperature?
    location_present? && temperature_expired_or_blank? || location_changed?
  end

  def temperature_expired_or_blank?
    # Do not need to update weather if request came from same location less than 5 min
    temperature.blank? || temperature_update_at < Time.now - 5.minutes
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

  def update_temperature(t, location)
    update(
      temperature: t,
      location_name: location,
      temperature_update_at: Time.now
    )
  end

  def update_location(lat, long)
    update(
      lat: lat,
      long: long
    )
  end

  def update_user_info_from_fb(response)
    update(
      first_name: response['first_name'],
      last_name: response['last_name'],
      profile_pic: response['profile_pic']
    )
  end

  def weather_message!
    SendFbMessageJob.perform_later(
      facebook_id,
      {
        text: I18n.t( 'bot.weather_report', location_name: location_name, temparature: temperature.to_s )
      }
    )
  end

end