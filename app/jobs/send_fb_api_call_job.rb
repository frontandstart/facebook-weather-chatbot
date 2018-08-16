class SendFbApiCallJob < ApplicationJob
  queue_as :default

  def perform(type, fb_id)
    # Do something later
  end
end
