require 'first_plugin'

module ::Rails
  mattr_accessor :initializer
end

::Rails.initializer = self