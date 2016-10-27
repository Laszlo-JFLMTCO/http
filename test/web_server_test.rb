require 'minitest/autorun'
require 'faraday'
require 'pry'

class TestServer < Minitest::Test

  def test_server_can_listen
    response = Faraday.get("http://localhost:9292")
    assert_equal 200, response.status
  end

  def test_server_get_hello_returns_hello_world
    response = Faraday.get("http://localhost:9292/hello")
    assert response.body.include?("Hello World! (")
  end

  def test_server_post_started_game_returns_different_status
    response = Faraday.post("http://localhost:9292/start_game")
    assert_includes [301, 403], response.status
  end

  def test_server_get_request_unknown_path_returns_404
    response = Faraday.get("http://localhost:9292/fofamalou")
    assert_equal 404, response.status
  end

  def test_server_post_game_without_parameters_does_not_crash_server
    response = Faraday.post("http://localhost:9292/game")
    binding.pry
    assert_equal 200, response.status
  end

  def test_server_get_game_returns_details
    response = Faraday.post("http://localhost:9292/game")
    assert_equal 200, response.status
  
  end

end