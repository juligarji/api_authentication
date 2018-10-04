require 'test_helper'

class CalledControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get called_test_url
    assert_response :success
  end

end
