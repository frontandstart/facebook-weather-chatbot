HTTParty.post( ENV['FB_API_PATH'] + '/me/messenger_profile',  
  query: { access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER'] },
  body: {
    get_started: {
      payload: 'get_started'
    }   
  },
  headers: {'Content-Type'=>'application/json'}
)


{
  "persistent_menu": [
    {
      "locale":"default",
      "composer_input_disabled": true,
      "call_to_actions":[
        {
          {
            title: "Weather Report",
            type: "postback",
            payload: "weather_report"
          },
          {
            "type":"web_url",
            "title":"Latest News",
            "url":"https://www.messenger.com/",
            "webview_height_ratio":"full"
          }
        }
      ]
    }
  ]
}