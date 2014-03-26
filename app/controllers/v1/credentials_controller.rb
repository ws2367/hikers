class V1::CredentialsController < ApplicationController

  respond_to :json
  # NOTE that the helper method changes according to the namespace
  before_filter :authenticate_v1_user! #, :except => [:show, :index]  
  

  # GET /S3Credentials
  def create
    sts    = AWS::STS.new
    policy = AWS::STS::Policy.new

    # let's put the policy in this way first. We'll worry about it later
    policy.allow(:actions => ['s3:*'],
                 :resources => :any)
    
    #policy.allow(:action => ['s3:GetObject'],
    #             :resources => "arn:aws:s3:::xoxo_img/pictures/*")
             
    # duration is in seconds, ranging from 3600s to 129600s (36 hours)
    federated_session = sts.new_federated_session("TempUser", :policy => policy, :duration => 60 * 60)

    respond_to do |format|    
      format.json { render json: {"ACCESS_KEY_ID" => federated_session.credentials[:access_key_id], 
                                  "SECRET_KEY" => federated_session.credentials[:secret_access_key],
                                  "SESSION_TOKEN" => federated_session.credentials[:session_token],
                                  "expires_at" => federated_session.expires_at} }

    end
    
  end

end