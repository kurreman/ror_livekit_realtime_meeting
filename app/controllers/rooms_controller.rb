require 'livekit' # Might need this if directly interacting here

class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_livekit_client, only: [:index, :create] # Add :create later

  # GET /rooms
  def index
    begin
      response = @livekit_client.list_rooms
      @livekit_rooms = response.data.rooms || []
      # You might want to correlate LiveKit rooms with rooms in your DB
      # if you store extra info like images. For now, just list from LiveKit.
    rescue => e
      @livekit_rooms = []
      flash.now[:alert] = "Could not fetch rooms from LiveKit: #{e.message}"
    end
  end

  # GET /rooms/new (FR2.1)
  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    
    if @room.save
      # Success handling
      redirect_to rooms_path, notice: "Room was successfully created."
    else
      # Failure handling
      render :new, status: :unprocessable_entity
    end
  rescue => e
    # When rescuing from an exception, we need to initialize @room again
    @room = Room.new(room_params)
    flash.now[:alert] = "Error creating room: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  # app/controllers/rooms_controller.rb (in create action)
  # def create
  #   room_name = params.require(:room).permit(:name)[:name]
  #   begin
  #     # Create in LiveKit
  #     @livekit_client.create_room(name: room_name)

  #     # Create in local DB (handle potential race conditions/errors)
  #     @room = Room.find_or_create_by(name: room_name)
  #     # Maybe set a default image_url here?

  #     redirect_to authenticated_root, notice: "Room '#{room_name}' created successfully."
  #   rescue LiveKit::Error => e
  #     # Handle LiveKit error
  #     # ...
  #   rescue ActiveRecord::RecordInvalid => e
  #     # Handle DB validation error
  #     flash.now[:alert] = "Failed to save room data: #{e.message}"
  #     render :new, status: :unprocessable_entity
  #   end
  # end


  # GET /rooms/:id (FR2.2)
  def show
     # We need the room name to generate the token
     @room_name = params[:id] # Assuming the ID is the room name for simplicity
     # You might fetch room details from your DB if needed
     # Generate the LiveKit token here or in a separate action
  end


  # POST /rooms/:id/token (FR2.2)
  def token
    @room_name = params[:id] # Get room name from URL
    user_name = current_user.username # Get username from logged-in user

    api_key = ENV['LIVEKIT_API_KEY']
    api_secret = ENV['LIVEKIT_API_SECRET']

    unless api_key && api_secret
       return render json: { error: "LiveKit configuration missing." }, status: :internal_server_error
    end

    # Create the Access Token
    # Identity can be anything uniquely identifying the user
    # Grant permissions to join the room
    token = LiveKit::AccessToken.new(api_key: api_key, api_secret: api_secret)
    token.identity = user_name # Use Devise user's username
    token.add_grant(room_join: true, room: @room_name, can_publish: true, can_subscribe: true)

    render json: { token: token.to_jwt }

  # rescue LiveKit::Error => e
  #   render json: { error: "Failed to generate token: #{e.message}" }, status: :internal_server_error
  rescue => e # Catch other potential errors
    render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
  end


  private

  # Share this method with LivekitApiController or move to ApplicationController/concern
  def set_livekit_client
    api_key = ENV['LIVEKIT_API_KEY']
    api_secret = ENV['LIVEKIT_API_SECRET']
    # Use the SERVICE URL for RoomServiceClient, usually HTTP/HTTPS
    livekit_url = ENV['LIVEKIT_URL'] # e.g., http://localhost:7880 or https://your-livekit-host

    unless api_key && api_secret && livekit_url
      Rails.logger.error("LiveKit API Key, Secret, or URL not configured.")
      flash[:alert] = "LiveKit configuration missing."
      redirect_to authenticated_root and return # Redirect or handle error
    end
    # Initialize the LiveKit client 

    @livekit_client = LiveKit::RoomServiceClient.new(livekit_url, api_key: api_key, api_secret: api_secret)
  end
end

def room_params
  params.require(:room).permit(:name)
end