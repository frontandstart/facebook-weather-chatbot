Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/facebook-messenger', to: 'users#facebook_messenger'
  post '/facebook-messenger', to: 'users#facebook_messenger'

  get '/tos', to: 'users#tos'
  get '/user_agreement', to: 'users#user_agreement'

end
