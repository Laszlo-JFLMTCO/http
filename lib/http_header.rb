require 'pry'
require_relative 'support'

class HttpHeader

  attr_reader :header,
              :header_clean,
              :header_keywords

  def initialize(header = [])
    @header = header
    @header_keywords = ["Connection", "Content-Length", "Cache-Control", "Origin", "User-Agent", "Content-Type", "Accept", "Accept-Encoding", "Accept-Language"]
  end

  def empty_header
    @header = []
    @header_clean = {}
  end

  def build_http_header(tcp_request_raw)
    empty_header
    tcp_request_raw.each do |tcp_one_line|
      @header << sanitize(tcp_one_line)
    end
    process_header
  end

  def process_header_first_line(input)
    header_first_line = splitting(header[0], " ")
    @header_clean["Verb"] = header_first_line[0]
    @header_clean["Path"] = header_first_line[1]
    @header_clean["Protocol"] = header_first_line[2]
  end

  def process_header_second_line(input)
    header_second_line = splitting(header[1], ": ")
    @header_clean["Host"] = splitting(header_second_line[1], ":").first
    @header_clean["Port"] = splitting(header_second_line[1], ":").last
  end

  def header_first
    header.first
  end

  def header_second
    header[1]
  end

  def process_header
    return if header.size < 2
    process_header_first_line(header_first)
    process_header_second_line(header_second)
    header_keywords.each do |keyword|
      keyword_line = nil
      keyword_line = header.find {|one_line| one_line.start_with?(keyword)}
      @header_clean[keyword] = splitting(keyword_line, ": ").last if !keyword_line.nil?
    end
  end

  def received(detail)
    header_clean[capitalize(detail)]
  end

  def diagnostics_report
    report_list = []
    @header_clean.keys.each do |item|
      report_list << "#{item}: " + @header_clean[item]
    end
    report_list.join("\n")
  end

  def diagnostics_report_raw
    report = header.join("\n")
  end
end