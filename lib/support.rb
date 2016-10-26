def sanitize(tcp_one_line)
  tcp_one_line.chomp
end

def splitting(input, divider)
  input.split(divider)
end

def read(dictionary_source)
  dictionary_content = File.read(dictionary_source)
  dictionary_content.split("\n")
end