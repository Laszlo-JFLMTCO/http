require_relative 'support'
require_relative 'http'

class ResponseBuilder
  attr_reader :path_processors,
              :http,
              :hello_counter

  def initialize
    @path_processors = {"/" => "diagnostics_report",
                        "/hello" => "say_hello",
                        "/close" => "close_server"}
    @http = Http.new
    @hello_counter = 0
  end

  def build_response(request_path)
    parameters = splitting(request_path, "/").last
    self.send(path_processors[request_path])
  end

  def build_http_header(input)
    http.build_http_header(input)
  end

  def pre_wrapper(response)
    "<pre>" + response + "</pre>"
  end

  def diagnostics_report
    http.diagnostics_report
  end

  def say_hello
    @hello_counter += 1
    response = "Hello World! (#{hello_counter})"
    pre_wrapper(response)
  end

  def close_server
    response = "Closing server => Server will stop listening... Bye! :-)"
    pre_wrapper(response)
  end

  def output
    build_response(http.received("path"))
  end

end