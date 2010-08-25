class ActressesController < ApplicationController
  def self.in_actresses_controller?
    true
  end
  
  def pay
    Actress
  end
end