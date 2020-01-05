module ActsAsIdentifier
  class Encoder
    attr_reader :max, :base, :chars, :mappings, :length

    def initialize(chars:, mappings:, length:)
      @chars = chars.dup
      @mappings = mappings.dup
      @length = length
      @xbase_integer = XbaseInteger.new(chars)
      @base = @xbase_integer.to_i("#{chars[1]}#{chars[0] * (length - 1)}")
      @max = @xbase_integer.to_i(chars[-1] * length) - @base
    end

    def encode(num)
      str = @xbase_integer.to_x(num + base)
      (str.length - 1).downto(1).each do |i|
        idx = @mappings.index(str[i])
        idx2 = (@mappings.index(str[i - 1]) + idx) % @mappings.size
        str[i] = @chars.at(idx)
        str[i - 1] = @chars.at(idx2)
      end
      str
    end

    def decode(str)
      str = str.dup
      0.upto(str.length - 2).each do |i|
        idx = @chars.index(str[i + 1])
        idx2 = (@chars.index(str[i]) - idx + @chars.size) % @chars.size
        str[i] = @mappings.at(idx2)
        str[i + 1] = @mappings.at(idx)
      end
      @xbase_integer.to_i(str) - base
    end
  end
end
