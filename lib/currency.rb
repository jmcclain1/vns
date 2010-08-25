require 'bigdecimal'

class BigDecimal
  # Pretty currency formatter for BigDecimal numbers
  def to_currency(symbol = '$', decimal = '.', separator = ',')
    _, dollars, cents = /([\d]+).([\d]+)/.match(round(2).to_s('F')).to_a
    cents += '0' unless cents.size == 2
    groups, offset = dollars.size.divmod(3)
    if groups > 0
      if offset > 0
        dollars[offset,0] = separator
        offset += 1
      end
      while offset < dollars.size - 3
        dollars[offset+3,0] = separator
        offset += 4
      end
    end
    "#{symbol}#{dollars}#{decimal}#{cents}"
  end
end

class String
  def to_currency(symbol = '$', decimal = '.', separator = ',')
    BigDecimal(self).to_currency(symbol,decimal,separator)
  end
end
