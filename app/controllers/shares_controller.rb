class SharesController < ApplicationController

  respond_to :json
  

  # POST /shares
  def create
    @user = User.find(params[:user_id])
    #@share = @user.shares.new(params[:share])
    #@share = @user.shares.new(params[:share])
    #@share.numbers = params[:tel]
    #@share.numbers.push(params[:tel])
    respond_to do |format|
    	#if @share.save
      		format.json { render json: @user}
      #end
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

  # POST /addnumshares
  def update
    @share = Shares.where(sharee_id: params[:sharee_id])
    @share.push(params[:tel])
    respond_to do |format|
      if @share.save
          format.json { render json: @share }
      end
    end
  end
end
