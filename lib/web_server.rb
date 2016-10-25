require 'socket'
require_relative 'http'

tcp_server = TCPServer.new(9292)
http_request = Http.new

stop_listening = false
puts "Server is listening..."
request_counter = 0

while !stop_listening do
  client = tcp_server.accept
  puts "Received #{request_counter} HTTP requests since started..."
  while line = client.gets and !line.chomp.empty?
    stop_listening = true if line.include?("close")
    http_request.build_http_header(line)
  end
  response = "<pre>" + "Hello World! (#{request_counter})\n" + "</pre>"
  output = "<html><head></head><body>#{response}</body></html>"
  headers = ["http/1.1 200 ok",
            "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
            "server: ruby",
            "content-type: text/html; charset=iso-8859-1",
            "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  client.puts headers
  client.puts output
  request_counter += 1
end

client.close
puts "Server STOPPED listening! Bye!"
