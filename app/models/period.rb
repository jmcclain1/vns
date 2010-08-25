class Period

  TWO_DAYS = 2
  THREE_DAYS = 3
  ONE_WEEK = 7

  def self.all_for_select
    [
      ['2 days', Period::TWO_DAYS],
      ['3 days', Period::THREE_DAYS],
      ['1 week', Period::ONE_WEEK],
    ]
  end

  def self.description(days)
    pair = all_for_select.select do |pair|
      pair.last == days
    end.first
    if pair.nil?
      "None"
    else
      pair.first
    end
  end

  def initialize(start, duration)
    @start = start
    @duration = duration
  end

  def start
    @start || Time.now
  end

  def end
    start + @duration.day
  end
end
