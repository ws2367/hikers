class UsersController < ApplicationController

  respond_to :json
  

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
