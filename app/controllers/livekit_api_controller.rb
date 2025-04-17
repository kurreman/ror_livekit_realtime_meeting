require 'livekit'

class LivekitApiController < ApplicationController
  before_action :authenticate_user! # Ensure user is logged in
  before_action :set_livekit_client

  # GET /livekit/rooms
  def list_rooms
    begin
      @rooms = @livekit_client.list_rooms
      # Render JSON or use this data in another controller/view
      render json: @rooms
    rescue LiveKit::LivekitError => e
      render json: { error: "Failed to fetch rooms from LiveKit: #{e.message}" }, status: :internal_server_error
    end
  end

  # POST /livekit/rooms (Example for creation - FR2.1)
  def create_room
    room_name = params.require(:room_name) # Get room name from form/request params
    begin
      @livekit_client.create_room(name: room_name)
      # Redirect or render success, maybe back to rooms list
      redirect_to authenticated_root, notice: "Room '#{room_name}' created successfully."
    rescue LiveKit::LivekitError => e
      # Handle error, e.g., room already exists
      redirect_to new_room_path, alert: "Failed to create room: #{e.message}"
    end
  end

  private

  def set_livekit_client
    # Use environment variables set in your Dockerfile/dev.env
    api_key = ENV['LIVEKIT_API_KEY']
    api_secret = ENV['LIVEKIT_API_SECRET']
    livekit_url = ENV['LIVEKIT_URL'] # e.g., 'http://localhost:7880' NO - should be like 'wss://your-host.livekit.cloud'

    unless api_key && api_secret && livekit_url
      Rails.logger.error("LiveKit API Key, Secret, or URL not configured.")
      # Render an error or handle appropriately
      render json: { error: "LiveKit configuration missing." }, status: :internal_server_error
      return false # Stop execution
    end

    @livekit_client = LiveKit::RoomServiceClient.new(livekit_url, api_key, api_secret)
  end
end