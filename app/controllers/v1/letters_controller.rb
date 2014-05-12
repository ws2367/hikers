class V1::LettersController < ApplicationController
  
  # GET /letters/check
  def check
    render :status => 200,
           :json => {:message => "Welcome! %s" % request.user_agent }
  end  
end
