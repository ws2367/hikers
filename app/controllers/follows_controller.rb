class FollowsController < ApplicationController

  respond_to :json
  

  # POST /follows
  def create
    @user = User.find(params[:user_id])
    @follow = @user.follows.new(params[:follow])
    respond_to do |format|
    	if @follow.save
      		format.json { render json: @follow }
      end
    end
  end

  # DELETE /follows/1
  def destroy
    @follow = Follow.find(params[:id])
    @follow.destroy
    respond_to do |format|
        format.json { render json:  @follow}
    end
  end
end
