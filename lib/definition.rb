module Definition

    PATH_PROCESSORS = {"/"=>"diagnostics_report",
                        "/hello"=>"say_hello",
                        "/datetime"=>"date_time",
                        "/shutdown"=>"shutdown_server",
                        "/word_search"=>"word_search",
                        "/start_game"=>"start_guessing_game",
                        "/game"=>"guessing_game",
                        "/force_error"=>"force_error"}
    RESPONSE_CODES = {"200"=>"OK",
                        "301"=>"Moved Permanently",
                        "302"=>"Temporary Redicrect",
                        "401"=>"Unauthorized",
                        "403"=>"Forbidden",
                        "404"=>"Not Found",
                        "500"=>"Internal Server Error"}



end