require 'json'
require './line_parser'

def help_message
    puts "Command not found. Did you mean: "
    puts "ruby file_to_json.rb <input_file> <output_file>"
end

def format_json(hash_array)
    hash_array.map { |hash| JSON.pretty_generate(hash) }.join(",\n")
end

def exec
    if(ARGV.length != 2)
        help_message
        exit
    end

    input_file = ARGV[0]
    output_file = ARGV[1]

    file_parser = LineParser.new
    parsed_input = file_parser.parse_from_file(input_file)
    json_string = format_json(parsed_input)

    fJson = File.open(output_file, "w")
    fJson.write(json_string)
    fJson.close
end

exec