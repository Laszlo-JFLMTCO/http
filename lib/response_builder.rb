require_relative 'support'
require_relative 'http'

class ResponseBuilder
  attr_reader :path_processors,
              :http,
              :hello_counter,
              :all_request_counter

  def initialize
    @path_processors = {"/"=>"diagnostics_report",
                        "/hello"=>"say_hello",
                        "/datetime"=>"date_time",
                        "/shutdown"=>"shutdown_server"}
    @http = Http.new
    @hello_counter = 0
  end

  def build_response(request_path)
    return pre_wrapper("Not supported path") if !path_processors.keys.include?(request_path)
    parameters = splitting(request_path, "/").last
    response = self.send(path_processors[request_path])
    pre_wrapper(response)
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
  end

  def current_date_time
    Time.now.strftime("%I:%M%p on %A, %B %e, %Y")
  end

  def date_time
    response = "#{current_date_time}"
  end

  def shutdown_server
    response = "Total Requests: #{all_request_counter}"
  end

  def output(webserver_counter)
    @all_request_counter = webserver_counter
    build_response(http.received("path"))
  end

end