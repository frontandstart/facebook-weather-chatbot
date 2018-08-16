class SendFbMessageJob < ApplicationJob
  queue_as :default

  def perform(facebook_id, message_text)
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
  end
end
