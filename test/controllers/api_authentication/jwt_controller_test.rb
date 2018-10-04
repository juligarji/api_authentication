require 'test_helper'

module ApiAuthentication
  class JwtControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

     test "token login " do
      get 'http://localhost:3000/jwt_controller/test'
      assert_response :success
     end
  end
end
