class ParseLine
    attr_reader :hash_line

    def initialize(feature, date_range, price)
        @feature = feature
        @date_range = date_range
        @price = price
        @hash_line = { feature: @feature, date_range: @date_range, price: @price }
    end
end