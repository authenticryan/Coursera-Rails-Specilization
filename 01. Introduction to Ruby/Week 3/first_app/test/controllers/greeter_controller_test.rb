require 'test_helper'

class GreeterControllerTest < ActionDispatch::IntegrationTest
  test "should get hello" do
    get greeter_hello_url
    assert_response :success
  end

  test "should get goodbye" do
    get greeter_goodbye_url
    assert_response :success
  end

end
