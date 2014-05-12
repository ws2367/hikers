class V1::LettersController < ApplicationController
  
  # GET /letters/check
  def check
    render :status => 200,
           :json => {:letter => "Welcome! %s" % request.user_agent }
  end  
end
