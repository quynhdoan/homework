require './parse_model'

class LineParser

    def parse_from_file(input_file)
        parsed_lines = []
        File.open(input_file, "r"). each do |line|
            feature = parse_feature(line)
            date_range = parse_date_range(line)
            price = parse_price(line)
            newLine = ParseLine.new(feature, date_range, price)
            parsed_lines << newLine.hash_line
        end
        parsed_lines
    end

    private
    def parse_feature(input_string)
        input_string.match(/[a-zA-Z]+[\s]+[\D]+[\d]*/).to_s
    end

    def parse_date_range(input_string)
        input_string.scan(/[\d]*+[\/]+[\d]*+\W*/).join.strip
    end

    def parse_price(input_string)
        input_string.match(/[\d]*+\.+[0-9][0-9]$/).to_s.to_f
    end
end