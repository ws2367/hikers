class V1::PostsController < ApplicationController
  
  respond_to :json
  before_filter :authenticate_v1_user!

  def map_institution_and_create_response hash
    location = Location.find(hash["location_id"])
    puts "location " + location.id.to_s
    inst = location.institutions.new(name: hash["name"],
                                     uuid: hash["uuid"],
                                     user_id: current_v1_user.id)
    response = Hash.new
    response = { id: inst.id, uuid: inst.uuid, updated_at: inst.updated_at.to_f} if inst.save!

    return response
  end

  def map_entity_and_create_response hash
    inst = Institution.find_by_uuid(hash["institution_uuid"])

    entity = inst.entities.new(fb_user_id: hash["fb_user_id"].to_i,
                               name: hash["name"],
                               uuid: hash["uuid"],
                               user_id: current_v1_user.id)

    respnose = Hash.new
    response = { id: entity.id, uuid: entity.uuid, updated_at: entity.updated_at.to_f} if entity.save!

    return response
  end

  def map_post_and_create_response hash

    post = Post.new(:content=>hash["content"], 
                    :uuid=>hash["uuid"],
                    :deleted => false)

    response = Hash.new
    if post.save
      response["id"] = post.id
      response["uuid"] = post.uuid
      response["updated_at"] = post.updated_at.to_f 
    end

    if hash["entities_uuids"]
      hash["entities_uuids"].each { |entity_uuid|
        puts entity_uuid
        entity = Entity.find_by_uuid(entity_uuid)
        Connection.create(post_id: post.id, entity_id: entity.id)
      }
    else
      puts "[ERROR] post does not include entity uuids. The association cannot be created."
    end

    return response
  end

  #POST /posts
  def create

    @response = Hash.new
    institutions = params["Institution"]
    if institutions
      if institutions.class == Array
        institution_response = institutions.collect {|inst| map_institution_and_create_response inst}
      else # if it is a single object
        instituttion_response = map_institution_and_create_response institutions
      end
      @response["Instiution"] = institution_response
      puts "insitituion"
    end

    entities = params["Entity"]
    if entities
      if entities.class == Array
        entitiy_response = entities.collect {|entity| map_entity_and_create_response entity}
      else
        entitiy_response = map_entity_and_create_response entities
      end
      @response["Entity"] = entitiy_response
      puts "entity"
    end

    keypath = params["Post"]
    if keypath.class == Array
      post_response = keypath.collect { |post| map_post_and_create_response post}
    else 
      post_response = map_post_and_create_response keypath      
    end
    @response["Post"] = post_response

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
          neadd_entities_against_client_matched_entities(@results[i], post, param[:Entity])w_entity.institution = new_institution
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


  def add_entities_against_client_matched_entities(post, entity_ids)
    if entity_ids 
      @result["entities"] = post.entities.collect { |ent| ent
        hash = Hash.new
        if entity_ids.find_index(ent.id)
          hash = {:id => ent.id}
        else
          hash = {
            :id => ent.id,
            :uuid => ent.uuid,
            :name => ent.name, 
            :updated_at => ent.updated_at.to_f,

            #meta attributes
            :is_your_friend => 1,
            :fb_user_id => 0,
            :institution => {
              :id => ent.institution.id

            }
          }
          hash[:institution][:location_id] = 
            ent.institution.location.id if ent.institution and 
                                           ent.institution.location
        end
        hash
      }
    else
      @result["entities"] = post.entities.collect { |ent| ent
        hash = {
          :id => ent.id,
          :uuid => ent.uuid,
          :name => ent.name, 
          :updated_at => ent.updated_at.to_f,

          #meta attributes
          :is_your_friend => 1,
          :fb_user_id => 0,
          :institution => {
            :id => ent.institution.id
          }
        }
        hash[:institution][:location_id] = 
          ent.institution.location.id if ent.institution and 
                                         ent.institution.location
                                         
        hash
      }
    end
  end

  def remove_client_matched_posts(client_posts_ids)
    puts client_posts_ids
    @posts.select {|post| !client_posts_ids.find_index(post.id) } if client_posts_ids
  end

  def query_popular_posts
    if @start_over
      @posts = Post.top.limit(5)
    else
      #popularity = Post.find(@last_of_previous_post_ids).popularity
      #TODO: this is a workaround, but I believe SQL and activerecord can do better
      start  = Post.top.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start 
        start += 1
        @posts = Post.top.slice(start, 5)
      else
        @posts = Array.new
      end
    end
  end

  def query_friends_posts

  end

  def query_following_posts

  end

  def query_posts_for_entity entity
    if @start_over
      @posts = entity.posts.order("updated_at desc").limit(5)
    else
      # begin #TODO: move this to outter loop so we hav protection on the whole thing
      #   updated_date = Post.find(@last_of_previous_post_ids).updated_at
      # rescue
      #   puts "Post#index: can't find the last post id of previous posts"
      # end
      start = entity.posts.order("updated_at desc").index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start 
        start += 1
        @posts = entity.posts.order("updated_at desc").slice(start, 5)        
      else
        @posts = Array.new
      end
      # @posts = entity.posts.where("posts.updated_at < ?", updated_date).limit(5)
    end
  end

  # GET /posts or GET /entities/:id/posts
  def index
    @posts = Array.new #prevent @posts from being null

    @start_over = false
    if params[:last_of_previous_post_ids]
      @last_of_previous_post_ids = params[:last_of_previous_post_ids]
    else
      @start_over = true
    end

    # handle different types
    if params[:entity_id]
      entity_id = params[:entity_id]
      entity = Entity.find(entity_id)
      # Entity does not exist!
      logger.info("Post#index: Entity #{entity_id} does not exist") unless entity

      query_posts_for_entity entity

    elsif params[:type]
      type = params[:type]
      if type == "popular"
        query_popular_posts

      elsif type == "friends"
        query_friends_posts

      elsif type == "following"
        query_following_posts

      else
        logger.info("Post#index: Wrong type of request: #{type}")
      end
    else
      logger.info("Post#index: Missing either entity_id or type in parameters")
    end

    remove_client_matched_posts(params[:Post]) #@posts cannot be null!

    @results = Array.new
    # TODO: Query in batch
    # this is bad because it queries the DB as many times as the number of posts
    @posts.each_with_index {|post, i|
      @result = {
        :id => post.id,
        :uuid => post.uuid,
        :content => post.content,
        :updated_at => post.updated_at.to_f, #TODO: limit to 3-digit precision
        :deleted => post.deleted,

        # meta attributes
        :is_yours => 0, #TODO: compare current user and this user id
        :following => 0, #TOOD: check follow table
        :popularity => post.popularity
      }
      
      # association
      # this method checks the nullity of param[:Entity]
      # TODO: remove @results[i] from arguments since it is accessible in the method
      add_entities_against_client_matched_entities(post, params[:Entity])
      @results << @result
    }

    # prepare institution information
    institution_response = Hash.new
    if params["Institution"]
      institution_id = params["Institution"]
      
      inst = nil
      begin
        inst = Institution.find(institution_id)
      rescue
        logger.info("Institution ID #{institution_id} cannot be found.")
      end
      
      institution_response = {
          :id => inst.id,
          :uuid => inst.uuid,
          :name => inst.name,
          :deleted => inst.deleted,
          :updated_at => inst.updated_at
        } if inst

        institution_response[:location_id] = inst.location.id if inst and inst.location
    end

    @response = Hash.new
    @response["Post"] = @results
    @response["Institution"] = institution_response if institution_response.count > 0

    puts @response
    respond_to do |format|
       format.json { render json: @response }
    end
  end

  # GET /posts/1
  def show
    @post = Post.find(params[:id])
    respond_to do |format|
          format.json { render json: @post }
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
