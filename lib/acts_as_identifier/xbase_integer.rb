module ActsAsIdentifier
  class XbaseInteger
    attr_reader :chars
    def initialize(chars)
      @chars = chars.dup
    end

    def to_i(str)
      sum = 0
      str.chars.reverse.each_with_index do |char, i|
        sum += chars.index(char) * chars.size**i
      end
      sum
    end

    def to_x(num)
      str = chars.at(num % chars.size)
      num /= chars.size
      str = "#{to_x(num)}#{str}" if num > 0
      str
    end
  end
end
