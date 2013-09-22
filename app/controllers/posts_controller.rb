class PostsController < ApplicationController

  respond_to :json

  # POST /posts
  def create
    @entity = Entity.find(params[:entity_id])
    @post = @entity.posts.new(params[:post])
    respond_to do |format|
    	if @post.save
      		format.json { render json: @post }
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

  # GET /posts
  def index
    num = params[:num]
    sortby = params[:sortby]
    if sortby == "popularity"
      @posts = Post.find(:all, :order => "followersNum DESC", :limit => num)
    elsif sortby == "recent"
      @posts = Post.find(:all, :order => "created_at DESC", :limit => num)
    elsif sortby == "nearby"
    end
    respond_to do |format|
       format.json { render json: @posts }
    end
  end

  # GET /searchposts
  def search
    content = params[:content]
    num = params[:num]
    searchby = params[:searchby]
    if searchby == location
      @location = Location.where(name: content).limit(3)
      
    end
    @posts = Post.where(name: name).limit(params[:num])
    respond_to do |format|
       format.json { render json: @posts }
    end
  end

  # DELETE /posts/1
  def destroy
    @post = Comment.find(params[:id])
    @post.status = false
    respond_to do |format|
      if @post.save
        format.json { render json:  @post}
      end
    end
  end
end
