class UsersController < ApplicationController

  respond_to :json
  
#authentication key can be either user_name or device_token
protected
def self.find_first_by_auth_conditions(warden_conditions)
  conditions = warden_conditions.dup
  if login = conditions.delete(:login)
    where(conditions).where(["lower(user_name) = :value OR lower(device_token) = :value", { :value => login.downcase }]).first
  else
    where(conditions).first
  end
end

  # POST /users
  def create
    @user = User.new(params[:user])

    respond_to do |format|
    	if @user.save
      		format.json { render json: @user }
      	end
    end
  end

  # GET /users/1
  def show
  	@user = User.find(params[:id])
  	respond_to do |format|
      		format.json { render json: @user }
    end
  end

  # DELETE /users/1
  def destroy
  	@user = User.first
  	#@user = User.find(params[:id])
  	#@user.status = false
  	#@user.save!
  	respond_to do |format|
      	format.json { render json:  @user}
    end
  end
end
