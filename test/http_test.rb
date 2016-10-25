require 'minitest/autorun'
require './lib/http'
require './lib/support'

class HTTPTest < Minitest::Test
  def test_initialize
    assert Http.new
  end

  def test_build_http_header_with_one_line
    test_http = Http.new
    test_one_tcp_line = "GET / HTTP/1.1"
    test_http.build_http_header(test_one_tcp_line)
    assert test_http.header.include?(test_one_tcp_line)
  end

  def test_build_http_header_with_multiple_lines
    test_http = Http.new
    test_one_tcp_line = "GET / HTTP/1.1\r\n"
    test_http.build_http_header(test_one_tcp_line)
    test_one_tcp_line = "Host: localhost:9292\r\n"
    test_http.build_http_header(test_one_tcp_line)
    test_one_tcp_line = "Connection: keep-alive\r\n"
    test_http.build_http_header(test_one_tcp_line)
    assert test_http.header.include?("Host: localhost:9292")
  end

  def test_sanitizer
    assert_equal "GET /close HTTP/1.1", sanitize("GET /close HTTP/1.1\r\n")
  end

  def test_header_verb_path_protocol_identified
    test_http = Http.new
    test_one_tcp_line = "GET / HTTP/1.1"
    test_http.build_http_header(test_one_tcp_line)
    assert_equal "GET", test_http.header_clean["Verb"]
    assert_equal "/", test_http.header_clean["Path"]
    assert_equal "HTTP/1.1", test_http.header_clean["Protocol"]
  end

  def test_header_host_port_identified
    test_http = Http.new
    test_one_tcp_line = "GET / HTTP/1.1\r\n"
    test_http.build_http_header(test_one_tcp_line)
    test_one_tcp_line = "Host: localhost:9292\r\n"
    test_http.build_http_header(test_one_tcp_line)
    assert_equal "localhost", test_http.header_clean["Host"]
    assert_equal "9292", test_http.header_clean["Port"]
  end

  def test_divide_by_space
    assert_equal ["GET", "/", "HTTP/1.1"], splitting("GET / HTTP/1.1", " ")
  end

end