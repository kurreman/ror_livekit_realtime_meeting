# filepath: /workspaces/ror_livekit_realtime_meeting/config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  
  # Authentication-based root routes
  authenticated :user do
    root 'rooms#index', as: :authenticated_root
  end
  
  devise_scope :user do
    root to: "devise/sessions#new"
  end
  
  # Use only resource-style routes for rooms
  # Register the token route to allow the Javascript browser client to get a token for the room from the Rails backend
  resources :rooms, only: [:index, :new, :create, :show] do
    member do
      post 'token'
    end
  end
  
  # LiveKit API routes
  get '/livekit/rooms', to: 'livekit_api#list_rooms'
  post '/livekit/rooms', to: 'livekit_api#create_room'
end