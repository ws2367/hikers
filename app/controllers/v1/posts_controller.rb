class V1::PostsController < ApplicationController
  
  respond_to :json
  before_filter :authenticate_v1_user!

  def map_institution_and_create_response hash
    #TODO: we might not want to create a new institution every time
    inst = Institution.new(name: hash["name"],
                           uuid: hash["uuid"],
                           user_id: current_v1_user.id)

    # if the institution belongs to a location
    if hash["location_id"]
      location = Location.find(hash["location_id"]) 
      inst.location_id = location.id if location
    end

    response = Hash.new
    if inst.save
      response = { id: inst.id, uuid: inst.uuid, updated_at: inst.updated_at.to_f} 
      puts "Institution_response: " + response.to_s
    else
      @error = true
    end

    return response
  end

  def map_entity_and_create_response hash
    # if in request, the fb_user_id is not 0 andthe entity of same fb_user_id exists, 
    # it does not create a new one. It sends back id, uuid, fb_user_id and updated_at. 
    entity = nil
    response = Hash.new
    # Note that nil.to_i = 0
    if hash["fb_user_id"].to_i != 0
      entity = Entity.find_by_fb_user_id(hash["fb_user_id"].to_i)
      if entity
        response = { id: entity.id, uuid: entity.uuid, 
                     fb_user_id: entity.fb_user_id, 
                     updated_at: entity.updated_at.to_f}
      end
    end

    # if it is not an existing FB entity, we create it anyway
    unless entity
      entity = Entity.new(name: hash["name"], 
                          uuid: hash["uuid"], 
                          user_id: current_v1_user.id)

      entity.fb_user_id = hash["fb_user_id"].to_i if hash["fb_user_id"]
      puts "fb_user_id: " + hash["fb_user_id"].to_s

      # if the entity belongs to an institution
      if hash["institution_uuid"]
        inst = Institution.find_by_uuid(hash["institution_uuid"]) 
        entity.institution_id = inst.id if inst
      end

      if entity.save
      response = { id: entity.id, uuid: entity.uuid, fb_user_id: entity.fb_user_id, 
                   updated_at: entity.updated_at.to_f} 
     else
      @error = true
     end
    end
    
    puts "is_your_friend: " + hash['is_your_friend']
    if hash['is_your_friend'] == '1' or hash['is_your_friend'] == 'true'
      Friendship.create(user_id: current_v1_user.id, entity_id: entity.id) 
    end

    return response
  end

  def map_post_and_create_response hash

    post = Post.new(:content=>hash["content"], 
                    :uuid=>hash["uuid"],
                    :deleted => false,
                    :user_id => current_v1_user.id)

    response = Hash.new
    if post.save
      response["id"] = post.id
      response["uuid"] = post.uuid
      response["updated_at"] = post.updated_at.to_f 
    else
      @error = true
      return response
    end

    has_entities = false
    if hash["entities_uuids"]
      hash["entities_uuids"].each do |entity_uuid|
        if entity = Entity.find_by_uuid(entity_uuid)
          if Connection.create(post_id: post.id, entity_id: entity.id)
            has_entities = true
          end
        end
      end
    end

    if hash["entities_fb_user_ids"]
      hash["entities_fb_user_ids"].each do |entity_fb_user_id|
        if entity = Entity.find_by_fb_user_id(entity_fb_user_id)
          if Connection.create(post_id: post.id, entity_id: entity.id)
            has_entities = true
          end
        end
      end
    end

    unless has_entities
      puts "[ERROR] post is not associated to any entity. The association cannot be created."
      unless post.destroy
        logger.info("Post #{post.id} canoot be destroyed.")
      end
      @error = true
    end

    return response
  end

  #POST /posts
  def create
    @error = false
    puts params
    @response = Hash.new
    institutions = params["Institution"]
    if institutions
      if institutions.class == Array
        institution_response = institutions.collect {|inst| map_institution_and_create_response inst}
      else # if it is a single object
        institution_response = map_institution_and_create_response institutions
      end
      @response["Instiution"] = institution_response
      puts "insitituion"
    end

    if @error
      render :status => 422,
               :json => {:message => "Institution cannot be set accordingly." }
      return
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

    if @error
      render :status => 422,
               :json => {:message => "Entity cannot be set accordingly." }
      return
    end

    keypath = params["Post"]
    if keypath.class == Array
      post_response = keypath.collect { |post| map_post_and_create_response post}
    else 
      post_response = map_post_and_create_response keypath      
    end
    @response["Post"] = post_response

    if @error
      render :status => 422,
               :json => {:message => "Post cannot be set accordingly." }
      return
    end

    puts @response
    respond_to do |format|
      format.json {render json: @response}
    end
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
            :is_your_friend => ent.is_friend_of_user(current_v1_user.id),
            :fb_user_id => ent.fb_user_id,
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
          :is_your_friend => ent.is_friend_of_user(current_v1_user.id),
          :fb_user_id => ent.fb_user_id,
          :institution => {}
        }
        
        if ent.institution 
          hash[:institution][:id] = ent.institution.id 
          if ent.institution.location
            hash[:institution][:location_id] = ent.institution.location.id
          end
        end
                                         
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
      @posts = Post.popular.limit(5)
    else
      #popularity = Post.find(@last_of_previous_post_ids).popularity
      #TODO: this is a workaround, but I believe SQL and activerecord can do better
      start_index  = Post.popular.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        end_index = start_index + 4
        end_index = Post.popular.all.count - 1 if end_index > (Post.popular.all.count - 1)
        puts "Popular: start_index: " + start_index.to_s + " end_index: " + end_index.to_s
        @posts = Post.popular.slice(start_index..end_index)
        
      else
        @posts = Array.new
      end
    end
  end

  def query_friends_posts
    user_id = current_v1_user.id
    if @start_over
      @posts = Post.about_friends_of(user_id).popular.limit(5)
    else
      #TODO: this is a workaround, but I believe SQL and activerecord can do better
      start_index  = Post.about_friends_of(user_id).popular.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = Post.about_friends_of(user_id).popular.all.count
        end_index = [(start_index + 4), (count - 1)].min
        puts "Friends: start_index: " + start_index.to_s + " end_index: " + end_index.to_s
        @posts = Post.about_friends_of(user_id).popular.slice(start_index..end_index)
        
      else
        @posts = Array.new
      end
    end
  end

  def query_following_posts
    if @start_over
      user_id = current_v1_user.id
      @posts = Post.followed_by(user_id).popular.limit(5)
    else
      start_index  = Post.followed_by(user_id).popular.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = Post.followed_by(user_id).popular.all.count
        end_index = [(start_index + 4), (count - 1)].min
        puts "Following: start_index: " + start_index.to_s + " end_index: " + end_index.to_s
        @posts = Post.followed_by(user_id).popular.slice(start_index..end_index)
        
      else
        @posts = Array.new
      end
    end
  end

  #TODO: my posts, not following posts
  def query_my_posts
    if @start_over
      user_id = current_v1_user.id
      @posts = Post.followed_by(user_id).popular.limit(5)
    else
      start_index  = Post.followed_by(user_id).popular.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = Post.followed_by(user_id).popular.all.count
        end_index = [(start_index + 4), (count - 1)].min
        puts "Following: start_index: " + start_index.to_s + " end_index: " + end_index.to_s
        @posts = Post.followed_by(user_id).popular.slice(start_index..end_index)
      else
        @posts = Array.new
      end
    end
  end

  def query_posts_for_entity entity
    if @start_over
      @posts = entity.posts.order("updated_at desc").limit(5)
    else
      start_index = entity.posts.order("updated_at desc").index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = entity.posts.order("updated_at desc").count
        end_index = [(start_index + 4), (count - 1)].min
        @posts = entity.posts.order("updated_at desc").slice(start_index..end_index) 
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
      puts "Start over"
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

      elsif type == "my"
        query_my_posts

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
        :is_yours => (current_v1_user.id == post.user_id), #TODO: compare current user and this user id
        :following => post.is_followed_by(current_v1_user.id),
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
      
      puts inst.to_json
      puts "id: " + institution_id.to_s

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

  # POST /posts/:id/follow
  def follow
    post_id = params[:post_id]
    unless post = Post.find(post_id)
      render :status => 400,
             :json => {:message => "Post #{post_id} does not exist." }
      return
    end

    if post.follows.create(user_id:current_v1_user.id)
      render status: 200, json: {}
    else
      render status: 422, json: {}
    end
    
  end

  # DELETE /posts/:id/unfollow
  def unfollow
    post_id = params[:post_id]
    unless post = Post.find(post_id)
      render :status => 400,
             :json => {:message => "Post #{post_id} does not exist." }
      return
    end

    follow = post.follows.find_by_user_id(current_v1_user.id)
    if follow 
      if follow.destroy
        render status: 200, json: {}
        return
      else
        render status: 422, 
        json: {:message => "Can't destroy the follow of post #{post_id} and user #{current_v1_user.id}"}
        return
      end
      render status: 400, 
      json: {:message => "Follow of post #{post_id} and user #{current_v1_user.id} does not exist."}
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
