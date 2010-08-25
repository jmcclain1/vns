class TermsOfServiceController < ApplicationController
  
  def show
    @terms_of_service = TermsOfService.latest
  end
  
end