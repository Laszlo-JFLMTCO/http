require 'minitest/autorun'
require './lib/response_builder'

class TestResponseBoulder < Minitest::Test
  def test_initializing
    assert ResponseBuilder.new
  end

  def test_path_processors_list
    #This test is only to support debugging
    skip
    assert_equal({}, ResponseBuilder.new.path_processors)
  end

  def test_pre_wrapper
    assert_equal "<pre>Hello World!</pre>", ResponseBuilder.new.pre_wrapper("Hello World!")
  end

  def test_current_date_time
    #This test is only to support debugging
    skip
    assert_equal "", ResponseBuilder.new.current_date_time
  end

  def test_path_command_returns_command_portion_from_http_request_path
    assert_equal "/path", ResponseBuilder.new.path_command("/path?param=value&param2=value2")
  end

  def test_path_command_returns_parameters_portion_from_http_request_path
    assert_equal "param=value&param2=value2", ResponseBuilder.new.path_parameters("/path?param=value&param2=value2")
  end

end