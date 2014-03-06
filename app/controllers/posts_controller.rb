class PostsController < ApplicationController
  
  #before_filter :authenticate_user! #, :except => [:show, :index]  
  respond_to :json

  def map_post_and_create_response hash

    post = Post.new(:content=>hash["content"], 
                        :uuid=>hash["uuid"],
                        :deleted => false)

    response = Hash.new
    if post.save
      response["id"] = post.id
      response["uuid"] = post.uuid
      response["updated_at"] = post.updated_at.to_f 
      puts "did saved"
    end

    hash["entities_ids"].each { |entity_id|
      puts entity_id
      Connection.create(post_id: post.id, entity_id: entity_id)
    }

    return response
  end

  #POST /posts
  def create
    keypath = params["Post"]
    if keypath.class == Array
      @response = Array.new
      @response = keypath.collect { |inst| create_institution_and_response inst}
    else # if it is a single object
      puts "Not array!"
      @response = map_post_and_create_response keypath      
    end

    puts @response
    respond_to do |format|
      format.json {render json: @response}
    end


  # let's not do the nested way
=begin
    new_post = Post.where( "uuid = ?", params["uuid"])[0]
    if new_post
      # do nothing
    else
      new_post = Post.new("content"=>params["content"], 
                          "uuid"=>params["uuid"])
    end

    if params["entities"].count > 0
      entities = params["entities"]
      entities.each do |entity|

        institution = entity["institution"]
        location = institution["location"]

        new_location = Location.where("name = ?", location["name"])[0]
        if new_location
          # do nothing
        else
          new_location = Location.new("name"=>location["name"])
          new_location.save! # so we have the id ready
        end
        new_institution = Institution.where("uuid = ?", institution["uuid"])[0]
        if new_institution
          # do nothing
        else
          new_institution = Institution.new(
            "name"=>institution["name"], 
            "uuid"=>institution["uuid"]
          )
          new_institution.location = new_location
          new_institution.save! # so we have the id ready
        end

        new_entity = Entity.where(" uuid = ?", entity['uuid'])
        if new_entity
          # update relationship with posts
        else 
          new_entity = Entity.new(
            "name" => entity["name"],
            "uuid" => entity["uuid"])
          new_entity.institution = new_institution
          new_post.entities << new_entity
          new_entity.save!
        end
      end
    end

    new_post.save!
    
    respond_to do |format|
      format.json { render status: :ok}
    end

=end
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

    #num = params[:num] # TODO: depreciated
    #sortby = params[:sortby] # TODO: depreciated

    #@posts = Post.find(:all, :order => "updated_at DESC", :limit => num)
    @posts = Post.where("updated_at > ?", Time.at(last_modified.to_f).utc)
    
    @results = Array.new
    # TODO: Query in batch
    # this is bad because it queries the DB as many times as the number of posts
    @posts.each_with_index {|post, i|
      @results[i] = Hash.new
      @results[i]["id"] = post.id
      @results[i]["content"] = post.content
      @results[i]["updated_at"] = post.updated_at.to_f #TODO: limit to 3-digit precision
      @results[i]["isYours"] = 0 #TODO: compare current user and this user id
      @results[i]["deleted"] = post.deleted
      @results[i]["uuid"] = post.uuid
      @results[i]["entities_ids"] = post.entities.collect { |ent| ent.id}
    }

=begin
    @posts.each_with_index {|post, i|
      @results[i] = Hash.new
      @results[i]["id"] = post.id
      @results[i]["content"] = post.content
      @results[i]["updated_at"] = post.updated_at.to_f #TODO: limit to 3-digit precision
      @results[i]["isYours"] = 0 #TODO: compare current user and this user id
      @results[i]["deleted"] = post.deleted
      @results[i]["uuid"] = post.uuid
      @results[i]["entities_ids"] = post.entities.collect { |ent| 
        {
          :id => ent.id,
          :name => ent.name, 
          :uuid => 234, #TODO: add uuid to db
          :updated_at => ent.updated_at.to_f,
          :institution => {
            "id" => ent.institution.id, 
            "name" => ent.institution.name, 
            "uuid" => 234, #TODO: add uuid to db
            "deleted" => false,
            "updated_at" => ent.institution.updated_at.to_f,
            :location => {
              "id" => ent.institution.location.id, 
              "name" => ent.institution.location.name
            }
          }
        } 
      }

      salt = rand(100000)
      @results[i]["comments"] = 
        post.comments.collect { |comment|
          {
            :id => comment.id,
            :anonymized_user_id => comment.user.id + salt, # TODO: set user_id differently if it's the poster
            :content => comment.content,
            :deleted => false, #TODO: add deleted to db
            :uuid => 234, #TODO: add uuid field to database
            :updated_at => comment.updated_at.to_f
          }
        }

      #logger.info("Picture id=#{@pic.id} is found.")
      
      # TODO: set up image url derived from S3 
    }
=end

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
