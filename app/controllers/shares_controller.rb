class SharesController < ApplicationController

  respond_to :json
  

  # POST /shares
  def create
    @user = User.find(params[:user_id])
    #@share = @user.shares.new(params[:share])
    @share = @user.shares.new(params[:share])
    respond_to do |format|
    	if @share.save
      		format.json { render json: @share }
      end
    end
  end

  # GET /shares/1
  def show
  	@post = Post.find(params[:id])
  	respond_to do |format|
      		format.json { render json: @post }
    end
  end

  # DELETE /shares/1
  def destroy
  	@user = User.first
  	#@user = User.find(params[:id])
  	#@user.status = false
  	#@user.save!
  	respond_to do |format|
      	format.json { render json:  @user}
    end
  end

  # PUT /shares/1
  def update
    @post = Post.find(params[:id])
    @share = @post.Shares.create
end
