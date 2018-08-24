Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/facebook-messenger', to: 'messages#facebook_messenger'
  post '/facebook-messenger', to: 'messages#facebook_messenger'

  get '/tos', to: 'messages#tos'
  get '/user_agreement', to: 'messages#user_agreement'

end