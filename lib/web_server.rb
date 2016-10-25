require 'socket'
require_relative 'response_builder'

tcp_server = TCPServer.new(9292)
# http_request = Http.new
response_builder = ResponseBuilder.new

stop_listening = false
puts "Server is listening..."
all_request_counter = 0

while !stop_listening do
  client = tcp_server.accept
  puts "Received #{all_request_counter} HTTP requests since started..."
  request_raw = []
  while line = client.gets and !line.chomp.empty?
    request_raw << line
  end
  response_builder.build_http_header(request_raw)
  response = response_builder.output(all_request_counter)
  output = "<html><head></head><body>#{response}</body></html>"
  stop_listening = true if output.include?("Total Requests")
  headers = ["http/1.1 200 ok",
            "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
            "server: ruby",
            "content-type: text/html; charset=iso-8859-1",
            "content-length: #{output.length}\r\n\r\n"].join("\r\n")

  client.puts headers
  client.puts output
  all_request_counter += 1
  client.close
end

puts "Server STOPPED listening! Bye!"
