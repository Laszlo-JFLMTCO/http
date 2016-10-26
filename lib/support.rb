def sanitize(tcp_one_line)
  tcp_one_line.chomp
end

def sanitize_post_parameters(input)
  parameters = {}
  input.gsub!("\r", "")
  input.gsub!("\n", "")
  useful_start = input.index("=\"") + 2
  useful_end = input.index("------WebKitForm", useful_start) - 1
  parameters[input[useful_start..useful_end].split("\"").first] = input[useful_start..useful_end].split("\"").last
  return parameters
end

def splitting(input, divider)
  input.split(divider)
end

def read(dictionary_source)
  dictionary_content = File.read(dictionary_source)
  dictionary_content.split("\n")
end

def capitalize(expression)
  expression.split("-").map do |word|
    word.capitalize
  end.join("-")
end