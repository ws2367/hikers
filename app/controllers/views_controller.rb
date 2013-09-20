class ViewsController < ApplicationController

  respond_to :json
  

  # POST /views
  def create
    @user = User.find(params[:user_id])
    @view = @user.views.new(params[:view])
    respond_to do |format|
    	if @view.save
      		format.json { render json: @view }
      end
    end
  end

  # GET /posts/1
  def show
  	@post = Post.find(params[:id])
  	respond_to do |format|
      		format.json { render json: @post }
    end
  end

  # DELETE /posts/1
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
