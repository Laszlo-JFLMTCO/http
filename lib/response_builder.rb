require_relative 'support'
require_relative 'http_header'
require_relative 'guessing_game'
require_relative 'definition'
require_relative 'features'

class ResponseBuilder
  include Definition
  include Features

  attr_reader :http_header,
              :hello_counter,
              :all_request_counter,
              :body_raw,
              :game,
              :response_header,
              :parameter_list

  def initialize
    @http_header = HttpHeader.new
    @hello_counter = 0
    @body_raw = ""
    @game = GuessingGame.new
    clean_status_code
    @parameter_list = {}
  end

  def path_command(request_path)
    splitting(request_path, "?").first
  end

  def path_parameters(request_path)
    splitting(request_path, "?").last
  end

  def is_valid?(command)
    PATH_PROCESSORS.keys.include?(command)
  end

  def build_response(request_path)
    command = path_command(request_path)
    parameter_parser("GET", path_parameters(request_path)) if get?
    parameter_parser("POST", @post_data) if post?
    return @status_code = "404" if !is_valid?(command)
    response = self.send(PATH_PROCESSORS[command])
    pre_wrapper(response)
  end

  def pre_wrapper(response)
    "<pre>#{response}</pre>"
  end

  def clean_status_code
    @status_code = "200"
    @new_url = nil
  end

  def create_response_header
    @response_header = ["http/1.1 #{@status_code} #{RESPONSE_CODES[@status_code]}",
                        "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                        "server: ruby",
                        "content-type: text/html; charset=iso-8859-1",
                        "content-length: #{body.length}\r\n\r\n"]
    @response_header.insert(1, "Location: #{@new_url}") if @status_code == "302"
  end

  def header
    create_response_header
    response_header.join("\r\n")
  end

  def body
    "<html><head></head><body>#{body_raw}</body></html>"
  end

  def output(webserver_counter, post_data)
    clean_status_code
    @all_request_counter = webserver_counter
    @post_data = post_data
    @body_raw = build_response(http_header.received("path"))
  end

  def build_http_header(input)
    http_header.build_http_header(input)
  end


  def get?
    http_header.received("verb") == "GET"
  end

  def post?
    http_header.received("verb") == "POST"
  end

  def parameter_parser_post(param_list)
    sanitize_post_parameters(param_list) if !param_list.empty?
  end

  def parameter_parser_get(param_list)
    parameter_list = {}
    splitting(param_list, "&").each do |pair|
      parameter_list[splitting(pair, "=").first] = splitting(pair, "=").last
    end
    parameter_list
  end

  def parameter_parser(get_post, param_list)
    @parameter_list = parameter_parser_get(param_list) if get?
    @parameter_list = parameter_parser_post(param_list) if post?
  end

  def post_content_length
    return nil if !post?
    http_header.received("Content-Length").to_i
  end

end