require 'minitest/autorun'
require './lib/http'
require './lib/support'

class HTTPTest < Minitest::Test
  def test_initialize
    assert Http.new
  end

  def test_sanitizer
    assert_equal "GET /close HTTP/1.1", sanitize("GET /close HTTP/1.1\r\n")
  end

  def test_header_verb_path_protocol_identified
    test_http = Http.new
    test_tcp_request_raw = ["GET / HTTP/1.1\r\n",
                            "Host: localhost:9292\r\n",
                            "Connection: keep-alive\r\n",
                            "Cache-Control: no-cache\r\n",
                            "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36\r\n",
                            "Accept: */*\r\n",
                            "Accept-Encoding: gzip, deflate, sdch\r\n",
                            "Accept-Language: en-US,en;q=0.8\r\n"]
    test_http.build_http_header(test_tcp_request_raw)
    assert_equal "GET", test_http.header_clean["Verb"]
    assert_equal "GET", test_http.received("verb")
    assert_equal "/", test_http.header_clean["Path"]
    assert_equal "/", test_http.received("path")
    assert_equal "HTTP/1.1", test_http.header_clean["Protocol"]
    assert_equal "HTTP/1.1", test_http.received("protocol")
  end

  def test_header_host_port_identified
    test_http = Http.new
    test_tcp_request_raw = ["GET / HTTP/1.1\r\n",
                            "Host: localhost:9292\r\n",
                            "Connection: keep-alive\r\n",
                            "Cache-Control: no-cache\r\n",
                            "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36\r\n",
                            "Accept: */*\r\n",
                            "Accept-Encoding: gzip, deflate, sdch\r\n",
                            "Accept-Language: en-US,en;q=0.8\r\n"]
    test_http.build_http_header(test_tcp_request_raw)
    assert_equal "localhost", test_http.header_clean["Host"]
    assert_equal "localhost", test_http.received("host")
    assert_equal "9292", test_http.header_clean["Port"]
    assert_equal "9292", test_http.received("port")
  end

  def test_divide_by_space
    assert_equal ["GET", "/", "HTTP/1.1"], splitting("GET / HTTP/1.1", " ")
  end

end