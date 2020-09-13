Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/sessions/join', to: 'sessions#join', as: 'join_session'
  post '/sessions/join', to: 'sessions#join_post', as: 'join_session_post'
  resources :sessions
  
end
