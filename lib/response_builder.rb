require_relative 'support'
require_relative 'http_header'
require_relative 'guessing_game'
require_relative 'definition'

class ResponseBuilder
  include Definition

  attr_reader :http_header,
              :hello_counter,
              :all_request_counter,
              :body_raw,
              :game,
              :response_header,
              :brand_new_parameter_list

  def initialize
    @http_header = HttpHeader.new
    @hello_counter = 0
    @body_raw = ""
    @game = GuessingGame.new
    clean_status_code
    @brand_new_parameter_list = {}
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
    brand_new_parameter_parser("GET", path_parameters(request_path)) if get?
    brand_new_parameter_parser("POST", @post_data) if post?
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

  def diagnostics_report
    http_header.diagnostics_report
  end

  def diagnostics_report_raw
    http_header.diagnostics_report_raw
  end

  def say_hello
    @hello_counter += 1
    "Hello World! (#{hello_counter})"
  end

  def current_date_time
    Time.now.strftime("%I:%M%p on %A, %B %e, %Y")
  end

  def date_time
    "#{current_date_time}"
  end

  def shutdown_server
    "Total Requests: #{all_request_counter}"
  end

  def brand_new_post_parameter_parser(param_list)
    sanitize_post_parameters(param_list) if !param_list.empty?
  end

  def brand_new_get_parameter_parser(param_list)
    parameter_list = {}
    splitting(param_list, "&").each do |pair|
      parameter_list[splitting(pair, "=").first] = splitting(pair, "=").last
    end
    parameter_list
  end

  def brand_new_parameter_parser(get_post, param_list)
    @brand_new_parameter_list = brand_new_get_parameter_parser(param_list) if get?
    @brand_new_parameter_list = brand_new_post_parameter_parser(param_list) if post?
  end

  def found_in_dictionary?(word)
    dictionary_content = read("/usr/share/dict/words")
    dictionary_content.one? {|one_line| one_line == word}
  end

  def word_search
    return if post?
    return "Missing parameter" if brand_new_parameter_list["word"].nil?
    value = brand_new_parameter_list["word"]
    return "#{value.upcase} is not a known word" if !found_in_dictionary?(value)
    return "#{value.upcase} is a known word"
  end

  def post_content_length
    return nil if !post?
    http_header.received("Content-Length").to_i
  end

  def start_guessing_game
    if post? and !game.started
      @status_code = "301"
      game.start
    elsif post? and game.started
      @status_code = "403"
    end
  end

  def evaluate_guess
    return "Your guess was missing, try again..." if brand_new_parameter_list.nil?
    @status_code = "302"
    @new_url = "http://localhost:9292/game"
    game.guess(brand_new_parameter_list["guess"].to_i)
  end

  def guessing_game
    return game.last_guess if get?
    evaluate_guess if post?
  end

  def force_error
    @status_code = "500"
    begin
      raise "SystemError"
      rescue => stack_trace
    end
    "#{stack_trace.backtrace.join("\n\t")}"
  end

end