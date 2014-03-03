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

  # GET /posts
  def index
    last_modified = params[:timestamp]

    num = params[:num] # TODO: depreciated
    sortby = params[:sortby] # TODO: depreciated

    #@posts = Post.find(:all, :order => "updated_at DESC", :limit => num)
    @posts = Post.where("updated_at > ?", Time.at(last_modified.to_i).utc)
    
    @results = Array.new

    @posts.each_with_index {|post, i|
      @results[i] = Hash.new
      @results[i]["id"] = post.id
      @results[i]["content"] = post.content
      @results[i]["updated_at"] = post.updated_at.to_f #TODO: limit to 3-digit precision
      @results[i]["isYours"] = 0 #TODO: compare current user and this user id
      @results[i]["uuid"] = 234 #TODO: add uuid field to database
      @results[i]["entities"] = post.entities.collect { |ent| 
        {
          :id => ent.id,
          :name => ent.name, 
          :updated_at => ent.updated_at.to_f,
          :institution => {
            "id" => ent.institution.id, 
            "name" => ent.institution.name, 
            "updated_at" => ent.institution.updated_at.to_f
          },
          :location => {
            "id" => ent.institution.location.id, 
            "name" => ent.institution.location.name,
            "updated_at" => ent.institution.location.updated_at.to_f
          }
        } 
      }

      salt = rand(100000)
      @results[i]["comments"] = 
        post.comments.collect { |comment|
          {
            :id => comment.id,
            :user_anonymozed_id => comment.user.id + salt,
            :content => comment.content,
            :uuid => 234, #TODO: add uuid field to database
            :updated_at => comment.updated_at.to_f
          }
        }

      #logger.info("Picture id=#{@pic.id} is found.")
      
      # TODO: set up image url derived from S3 
    }

    #respond_with @results
    respond_to do |format|
       format.json { render json: @results }
    end
  end

  # POST /orderposts
  def order
    num = params[:num]
    sortby = params[:sortby]
    if sortby == "popularity"
      @posts = Post.find(:all, :order => "followersNum DESC", :limit => num)
      @results = Array.new(num.to_i)
      @posts.each_with_index {|post, i|
        @results[i] = Hash.new
        @results[i]["content"] = post.content
        @results[i]["pic"] = "pic2";
        

        # the following lines are replaced by multiple entities in the next line 
        #@results[i]["entity"] = post.entities.first.name + ", " + 
        #                          post.entities.first.institution.name + ", " + 
        #                          post.entities.first.institution.location.name

        #@results[i]["entities"] = Hash.new(3)
        #@results[i]["entities"][0]["yes"]="1"
        #@results[i]["entities"][1]["no"]="2"

        @results[i]["entities"] = post.entities.collect { |en| {:name => en.name, :location => en.institution.location.name, :institution => en.institution.name} }

        #@results[i]["entities"] = post.entities

        #@results[i]["entities"] = Array.new
        #post.entities.each { |entity|
        #  @results[i]["entities"] << entity.name + ", " + 
        #                             entity.institution.name + ", " + 
        #                             entity.institution.location.name
        #}

      }
    elsif sortby == "recent"
      @posts = Post.find(:all, :order => "created_at DESC", :limit => num)
      @results = Array.new(num.to_i)
      @posts.each_with_index {|post, i|
        @results[i] = Hash.new
        @results[i]["content"] = post.content
        @results[i]["pic"] = "pic1";

        
        #@entitiesOfPost = post.entities

        
        # the following lines are replaced by multiple entities in the next line
        #@results[i]["entity"] = post.entities.first.name + ", " + 
        #                          post.entities.first.institution.name + ", " + 
        #                          post.entities.first.institution.location.name

        @results[i]["entities"] = post.entities.collect { |en| {:name => en.name, :location => en.institution.location.name, :institution => en.institution.name} }

        #@results[i]["entities"] = Array.new
        #post.entities.each { |entity|
        #  @results[i]["entities"] << entity.name + ", " + 
        #                             entity.institution.name + ", " + 
        #                             entity.institution.location.name
        #}
        
        #@pic  = post.pictures[0]
        #logger.info("Picture id=#{@pic.id} is found.")
        #redirect_to @pic.img.url
        @results[i]["pic"] = "pic1"
      }
      
    elsif sortby == "nearby"
    elsif sortby == "related"

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
