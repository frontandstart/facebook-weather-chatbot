HTTParty.post( ENV['FB_API_PATH'] + '/me/messenger_profile',  
  query: { access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] },
  body: {
    get_started: {
      payload: 'get_started'
    }   
  }.to_json,
  headers: {'Content-Type'=>'application/json'}
)

HTTParty.post( ENV['FB_API_PATH'] + 'me/messenger_profile',  
  query: { access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] },
  body: {
    persistent_menu: [
      {
        locale: "default",
        composer_input_disabled: false,
        call_to_actions: [
          {
            title: "Weather Report",
            type: "postback",
            payload: "weather_report"
          },
          {
            title: "Edit Locationt",
            type: "postback",
            payload: "edit_location"
          }
        ]
      }
    ]
  }.to_json,
  headers: {'Content-Type' => 'application/json'}
)


{
  "object"=>"page", 
  "entry"=>[
    {
      "id"=>"308568613245530",
      "time"=>1534535405986,
      "messaging"=>[
        {
          "recipient"=>{
            "id"=>"308568613245530"
          },
          "timestamp"=>1534535405986,
          "sender"=>{
            "id"=>"1993628157343502"
          },
          "postback"=>{
            "payload"=>"weather_report",
            "title"=>"Weather Report"
          }
        }
      ]
    }
  ], 
  "user"=>{}
}