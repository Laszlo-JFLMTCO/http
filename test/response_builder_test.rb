require 'minitest/autorun'
require './lib/response_builder'

class TestResponseBoulder < Minitest::Test
  def test_initializing
    assert ResponseBuilder.new
  end

  def test_path_processors_list
    skip
    assert_equal({}, ResponseBuilder.new.path_processors)
  end

  def test_pre_wrapper
    assert_equal "<pre>Hello World!</pre>", ResponseBuilder.new.pre_wrapper("Hello World!")
  end
end