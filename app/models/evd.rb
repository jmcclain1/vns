class Evd < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :evd_ro
end