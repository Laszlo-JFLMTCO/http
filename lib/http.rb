require 'pry'
require_relative 'support'

class Http

  attr_reader :header,
              :header_clean

  def initialize(header = [])
    @header = header
    @header_clean = {}
  end

  def build_http_header(tcp_one_line)
    @header << sanitize(tcp_one_line)
    process_header
  end

  def process_header
    header_first_line = splitting(header[0], " ")
    @header_clean["verb"] = header_first_line[0]
    @header_clean["path"] = header_first_line[1]
    @header_clean["protocol"] = header_first_line[2]
    if header.size > 1
      header_second_line = splitting(header[1], " ")
      header_second_line = splitting(header_second_line[1], ":")
      @header_clean["host"] = header_second_line[0]
      @header_clean["port"] = header_second_line[1]
    end
  end

end