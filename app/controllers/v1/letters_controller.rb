class V1::LettersController < ApplicationController
  
  # GET /letters/check
  def check
    version_number = request.user_agent[/Yours\/\d+/][6..-1].to_i
    logger.info("Client App Version: %i" % version_number)
    # if version_number == 313
    #   render :status => 200,
    #          :json => {:letter => "Welcome! %s" % request.user_agent }
    # end
    render :status => 200,
           :json => {}
  end  
end
