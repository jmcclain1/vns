if Object.const_defined?("RAILS_ENV") && RAILS_ENV =~ /test/
    require 'clock/mock_clock'
else
    require 'clock/real_clock'
end