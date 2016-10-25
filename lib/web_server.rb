require 'socket'
require_relative 'response_builder'

tcp_server = TCPServer.new(9292)
# http_request = Http.new
response_builder = ResponseBuilder.new

stop_listening = false
puts "Server is listening..."
request_counter = 0

while !stop_listening do
  client = tcp_server.accept
  puts "Received #{request_counter} HTTP requests since started..."
  request_raw = []
  while line = client.gets and !line.chomp.empty?
    stop_listening = true if line.include?("close")
    request_raw << line
  end
  response_builder.build_http_header(request_raw)
  # response = "<pre>" + "Hello World! (#{request_counter})\n" + "</pre>"
  response = response_builder.output
  output = "<html><head></head><body>#{response}</body></html>"
  headers = ["http/1.1 200 ok",
            "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
            "server: ruby",
            "content-type: text/html; charset=iso-8859-1",
            "content-length: #{output.length}\r\n\r\n"].join("\r\n")

  client.puts headers
  client.puts output
  request_counter += 1
  client.close
end

puts "Server STOPPED listening! Bye!"
