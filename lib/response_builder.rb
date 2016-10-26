require_relative 'support'
require_relative 'http'
require_relative 'guessing_game'

class ResponseBuilder
  attr_reader :path_processors,
              :http,
              :hello_counter,
              :all_request_counter,
              :parameters,
              :body_raw,
              :game,
              :response_header,
              :response_codes

  def initialize
    @path_processors = {"/"=>"diagnostics_report",
                        "/hello"=>"say_hello",
                        "/datetime"=>"date_time",
                        "/shutdown"=>"shutdown_server",
                        "/word_search"=>"word_search",
                        "/start_game"=>"start_guessing_game",
                        "/game"=>"guessing_game"}
    @response_codes = {"200"=>"OK",
                        "301"=>"Moved Permanently",
                        "302"=>"Temporary Redicrect",
                        "401"=>"Unauthorized",
                        "403"=>"Forbidden",
                        "404"=>"Not Found",
                        "500"=>"Internal Server Error"}
    @http = Http.new
    @hello_counter = 0
    @body_raw = ""
    @game = GuessingGame.new
    clean_response_header
    clean_status_code
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
    @post_parameters = post_parameter_parser if post?
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

  def get?
    http.received("verb") == "GET"
  end

  def post?
    http.received("verb") == "POST"
  end

  def diagnostics_report
    http.diagnostics_report
  end

  def diagnostics_report_raw
    http.diagnostics_report_raw
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

  def post_parameter_parser
    post_parameter_clean = sanitize_post_parameters(@post_data) if !@post_data.empty?
  end

  def parameter_parser(parameters)
    parameter_list = {}
    splitting(parameters, "&").each do |pair|
      parameter_list[splitting(pair, "=").first] = splitting(pair, "=").last
    end
    parameter_list
  end

  def found_in_dictionary?(dictionary_content, word)
    dictionary_content.one? {|one_line| one_line == word}
  end

  def word_search
    return if post?
    dictionary_content = read("/usr/share/dict/words")
    parameter_list = parameter_parser(parameters)
    parameter = "word"
    value = parameter_list[parameter]
    return "#{value.upcase} is not a known word" if !found_in_dictionary?(dictionary_content, value)
    return "#{value.upcase} is a known word"
  end

  def post_content_length
    return nil if !post?
    http.received("Content-Length").to_i
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
    post_parameter_parser
    game.guess(@post_parameters["guess"].to_i)
    @status_code = "302"
    @new_url = "http://localhost:9292/game"
  end

  def guessing_game
    return game.last_guess if get?
    evaluate_guess if post?
  end

  def clean_response_header
    @response_header = []
  end

  def clean_status_code
    @status_code = "200"
    @new_url = nil
  end

  def build_response_header
    clean_response_header
    @response_header << "http/1.1 " + @status_code + " " + response_codes[@status_code]
    @response_header << "Location: " + @new_url if @status_code == "302"
    @response_header << "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}"
    @response_header << "server: ruby"
    @response_header << "content-type: text/html; charset=iso-8859-1"
    @response_header << "content-length: #{body.length}\r\n\r\n"  
  end

  def header
    build_response_header
    response_header.join("\r\n")
  end

  def body
    "<html><head></head><body>#{body_raw}</body></html>"
  end

  def output(webserver_request_raw, webserver_counter, post_data)
    clean_status_code
    @all_request_counter = webserver_counter
    @post_data = post_data
    @body_raw = build_response(http.received("path"))
  end

end