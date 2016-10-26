require_relative 'support'
require_relative 'http'

class ResponseBuilder
  attr_reader :path_processors,
              :http,
              :hello_counter,
              :all_request_counter,
              :parameters

  def initialize
    @path_processors = {"/"=>"diagnostics_report",
                        "/hello"=>"say_hello",
                        "/datetime"=>"date_time",
                        "/shutdown"=>"shutdown_server",
                        "/word_search"=>"word_search"}
    @http = Http.new
    @hello_counter = 0
  end

  def path_command(request_path)
    splitting(request_path, "?").first
  end

  def path_parameters(request_path)
    splitting(request_path, "?").last
  end

  def is_valid?(command)
    path_processors.keys.include?(command)
  end

  def build_response(request_path)
    command = path_command(request_path)
    @parameters = path_parameters(request_path)
    return pre_wrapper(diagnostics_report_raw) if !is_valid?(command)
    response = self.send(path_processors[command])
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

  def diagnostics_report_raw
    http.diagnostics_report_raw
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

  def parameter_parser(parameters)
    parameter_value
    splitting(parameters, "&").each do |pair|
    end
  end

  def found_in_dictionary?(dictionary_content, word)
    dictionary_content.one? {|one_line| one_line == word}
  end

  def word_search
    dictionary_source = "./test/small_dictionary.txt"
    dictionary_content = read(dictionary_source)
    parameter = splitting(parameters, "=").first
    value = splitting(parameters, "=").last
    return "#{value.upcase} is a known word" if found_in_dictionary?(dictionary_content, value)
    return "#{value.upcase} is not a known word" if !found_in_dictionary?(dictionary_content, value)
  end

  def output(webserver_counter)
    @all_request_counter = webserver_counter
    build_response(http.received("path"))
  end

end