class SendFbMessageJob < ApplicationJob
  queue_as :default

  def perform(facebook_id, message_text, after_response_job)
    HTTParty.post( ENV['FB_API_PATH'] + '/me/messages',  
      query: { access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] },
      body: {
        recipient: {
          id: facebook_id
        },
        message: { 
          text: message_text,          
        }   
      },
      headers: {'Content-Type'=>'application/json'}
    )
    after_response_job if after_response_job.present?
  end
end
