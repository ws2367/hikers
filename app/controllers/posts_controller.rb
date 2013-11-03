class PostsController < ApplicationController
  
  #before_filter :authenticate_user! #, :except => [:show, :index]  
  respond_to :json

  #POST /posts
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

  # POST /orderposts
  def order
    num = params[:num]
    sortby = params[:sortby]
    if sortby == "popularity"
      @posts = Post.find(:all, :order => "followersNum DESC", :limit => num)
    elsif sortby == "recent"
      @posts = Post.find(:all, :order => "created_at DESC", :limit => num)
      @results = Array.new(num.to_i)
      @posts.each_with_index {|post, i|
        @results[i] = Hash.new
        @results[i]["content"] = post.content
        @results[i]["entity"] = post.entities.first.name + ", " + 
                                  post.entities.first.institution.name + ", " + 
                                  post.entities.first.institution.location.name
        #@results[i]["entities"] = Array.new
        #post.entities.each { |entity|
        #  @results[i]["entities"] << entity.name + ", " + 
        #                             entity.institution.name + ", " + 
        #                             entity.institution.location.name
        #}
        @results[i]["pic"] = "pic1";
      }
      
    elsif sortby == "nearby"
    end
    respond_to do |format|
       format.json { render json: @results }
    end
  end

  # POST /searchposts
  def search
    keyword = params[:keyword]
    num = params[:num]
    searchby = params[:searchby]
    if searchby == "location"
      @location = Location.where(name: keyword).limit(3)
      
      @posts = Post.where(name: name).limit(params[:num])
    elsif searchby == "content"
      @substring = '%' + keyword + '%'
      @posts = Post.where('content LIKE ?', @substring).limit(num)
    end
    
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
