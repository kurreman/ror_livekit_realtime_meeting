require "test_helper"

class LivekitApiControllerTest < ActionDispatch::IntegrationTest
  test "should get list_rooms" do
    get livekit_api_list_rooms_url
    assert_response :success
  end

  test "should get create_room" do
    get livekit_api_create_room_url
    assert_response :success
  end
end
