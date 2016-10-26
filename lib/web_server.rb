require 'socket'
require_relative 'response_builder'

tcp_server = TCPServer.new(9292)
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
  response_builder.output(request_raw, all_request_counter)
  stop_listening = true if response_builder.body.include?("Total Requests")

  client.puts response_builder.header
  client.puts response_builder.body
  all_request_counter += 1
  client.close
end

puts "Server STOPPED listening! Bye!"
