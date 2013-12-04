class CredentialsController < ApplicationController

  respond_to :json

  # GET get
  def get
    sts    = AWS::STS.new
    policy = AWS::STS::Policy.new
    policy.allow(:action => ['s3:GetObject'],
                 :resources => "arn:aws:s3:::xoxo_img/pictures/*")
             
    federated_session = sts.new_federated_session("TempUser", :policy => policy, :duration => 60 * 60)

    respond_to do |format|    
      format.json { render json: {"ACCESS_KEY_ID" => federated_session.credentials[:access_key_id], 
                                  "SECRET_KEY" => federated_session.credentials[:secret_access_key],
                                  "SESSION_TOKEN" => federated_session.credentials[:session_token]} }
    end
  end

end