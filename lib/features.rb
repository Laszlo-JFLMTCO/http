module Features

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

 def found_in_dictionary?(word)
    dictionary_content = read("/usr/share/dict/words")
    dictionary_content.one? {|one_line| one_line == word}
  end

  def word_search
    return if post?
    return "Missing parameter" if parameter_list["word"].nil?
    value = parameter_list["word"]
    return "#{value.upcase} is not a known word" if !found_in_dictionary?(value)
    return "#{value.upcase} is a known word"
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
    return "Your guess was missing, try again..." if parameter_list.nil?
    @status_code = "302"
    @new_url = "http://localhost:9292/game"
    game.guess(parameter_list["guess"].to_i)
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