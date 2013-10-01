class TokensController < ApplicationController

  skip_before_filter :verify_authenticity_token
  respond_to :json

  def create
    user_name = params[:user_name]
    password = params[:password]
    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
     return
    end
 
    if user_name.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user user_name and password."}
       return
    end
 
    @user=User.find_by_user_name(user_name)
 
    if @user.nil?
      logger.info("User #{user_name} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid user_name or passoword."}
      return
    end
 
    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!
 
    if not @user.valid_password?(password)
      logger.info("User #{user_name} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid user_name or password."}
    else
      render :status=>200, :json=>{:token=>@user.authentication_token}
    end
  end
 
  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end
 
end