class V1::SessionsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => :create
  #skip_before_filter :verify_authenticity_token
  respond_to :json

  def create #mapped to POST users/sign_in
    fb_access_token = params[:fb_access_token]
    app_id = 610309559054620
    app_secret = "8afb1403ddd477000e5393af310a8441"

  
    #user_name = params[:user_name]
    #password = params[:password]
    #if request.format != :json
    #  render :status=>406, :json=>{:message=>"The request must be json"}
    # return
    #end
 
    if fb_access_token.nil?
      render :status=>400,
             :json=>{:message=>"The request must contain the FB access token."}
      return
    end

    oauth = Koala::Facebook::OAuth.new(app_id, app_secret)
    app_access_token = oauth.get_app_access_token
    app_graph = Koala::Facebook::API.new(app_access_token)

    # check if the access token is valid and issued from our app 
    debug_info = app_graph.debug_token(fb_access_token)
    if debug_info["data"]["is_valid"] == false 
      render :status=>400,
             :json=>{:message=>"The FB access token is invalid"}
      return
    elsif debug_info["data"]["app_id"] != app_id.to_s
      render :status=>400,
             :json=>{:message=>"The FB access token is issued from other apps"}
      return
    end

    @graph = Koala::Facebook::API.new(fb_access_token)

    profile = @graph.get_object("me")

    fb_user_id = profile["id"].to_i
    location   = profile["location"]["name"]

    puts fb_user_id.to_s + ", " + location

    @user = User.find_by_fb_user_id(fb_user_id)
    
    if @user.nil?
      logger.info("User #{fb_user_id} failed signin. The user was then created.")
      @user = User.create(:fb_user_id=>fb_user_id, :fb_access_token=>fb_access_token)
      if @user.id.nil?
        render :status=>500, 
               :json=>{:message=>"User cannot be found or created"} 
      end
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!

    render :status=>200, :json=>{:token=>@user.authentication_token}

=begin
    if user_name.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user user_name and password."}
       return
    end
 
    @user = User.find_by_user_name(user_name)
 
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
=end
  end


  def destroy #mapped to DELETE users/sign_out 
    @user=User.find_by_authentication_token(params[:authentication_token])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{}
    end
  end

end