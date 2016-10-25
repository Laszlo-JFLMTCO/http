require 'pry'
require_relative 'support'

class Http

  attr_reader :header,
              :header_clean

  def initialize(header = [])
    @header = header

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

  def process_header
    header_first_line = splitting(header[0], " ")
    @header_clean["Verb"] = header_first_line[0]
    @header_clean["Path"] = header_first_line[1]
    @header_clean["Protocol"] = header_first_line[2]
    if header.size > 1
      header_second_line = splitting(header[1], " ")
      header_second_line = splitting(header_second_line[1], ":")
      @header_clean["Host"] = header_second_line[0]
      @header_clean["Port"] = header_second_line[1]
    end
    if header.size > 2
      @header_clean["Origin"] = ""
      header_x_line = splitting(header[4], " ")
      @header_clean["Accept"] = header_x_line[1]
    end
  end

  def received(detail)
    header_clean[detail.capitalize]
  end

  def diagnostics_report
    report = "<pre>"
    report_list = []
    @header_clean.keys.each do |item|
      report_list << "#{item}: " + @header_clean[item]
    end
    report += report_list.join("\n")
    report += "</pre>"
    return report
  end
end