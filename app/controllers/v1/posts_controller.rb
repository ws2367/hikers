class V1::PostsController < ApplicationController
  
  before_filter :authenticate_v1_user!

  def map_an_entity hash
    # In a request, the fb_user_id should not be 0 or nil.
    # It sends back id, uuid, fb_user_id and updated_at. 
    entity = nil
    # Note that nil.to_i = 0
    if hash["fb_user_id"].to_i != 0
      entity = Entity.find_by_fb_user_id(hash["fb_user_id"].to_i)
      if entity # if the entity exists
        return entity 
      else # if the entity does not exist
        entity = Entity.new(name: hash["name"], 
                            uuid: UUIDTools::UUID.random_create.to_s, 
                            fb_user_id: hash["fb_user_id"].to_i,
                            user_id: current_v1_user.id)

        entity.institution = hash["institution"] if hash["institution"]
        entity.location = hash["location"] if hash["location"]
        
        if entity.save
          puts "is_your_friend: " + hash['is_your_friend']
          if hash['is_your_friend'] == '1' or hash['is_your_friend'] == 'true'
            Friendship.create(user_id: current_v1_user.id, 
                              entity_id: entity.id) 
          end
          return entity

        else
          logger.info("[ERROR] Failed to create entity.")
          @error = true
          return nil
        end

      end
    else # if fb_user_id is not valid
      logger.info("[ERROR] Invalid entity fb_user_id")
      @error = true
      return nil
    end
  end
    

  def map_a_post(hash, entities)

    if entities.empty?
      logger.info("[ERROR] post is not associated to any entity. The association cannot be created.")
      @error = true 
      return nil
    end

    post = Post.new(content: hash["content"], 
                    uuid: hash["uuid"],
                    user_id: current_v1_user.id)

    unless post.save!
      logger.info("[ERROR] Failed to create post")
      @error = true
      return nil
    end

    for entity in entities
      if entity.valid?
        Connection.create(post_id: post.id, entity_id: entity.id)
      end
    end

    return post
  end

  #POST /posts
  def create
    @error = false
    puts params
    
    entitiesToMap = params["Entity"]
    if entitiesToMap
      if entitiesToMap.class == Array
        @entities = entitiesToMap.collect {|entity| map_an_entity entity}
      else
        @entities = [map_an_entity(entitiesToMap)] # make sure it is an array
      end
      puts "entity"
    end

    if @error
      render :status => 422,
             :json => {:message => "Entity cannot be set accordingly." }
      return
    end

    postsToMap = params["Post"]
    if postsToMap.class == Array
      @posts = postsToMap.collect { |post| map_a_post(post, @entities)}
    else 
      @posts = map_a_post(postsToMap, @entities)
    end
    
    if @error
      render :status => 422,
             :json => {:message => "Post cannot be set accordingly." }
      return
    end

    puts @entities
    puts @posts
    render "posts/create"
  end

=begin
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
            :fb_user_id => ent.fb_user_id
          }
          
          hash[:institution] = ent.institution if ent.institution 
          #hash[:location] = ent.location if ent.location
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
          :fb_user_id => ent.fb_user_id
        }

        hash[:institution] = ent.institution if ent.institution 
        #hash[:location] = ent.location if ent.location
                                         
        hash
      }
    end
  end

  def add_entities post
    @result["entities"] = post.entities.collect { |ent| ent
        hash = {
          :id => ent.id,
          :name => ent.name, 
          :updated_at => ent.updated_at.to_f,

          #meta attributes
          :is_your_friend => ent.is_friend_of_user(current_v1_user.id),
          :fb_user_id => ent.fb_user_id
        }

        hash[:institution] = ent.institution if ent.institution 
        #hash[:location] = ent.location if ent.location
                                         
        hash
      }
  end

  def remove_client_matched_posts(client_posts_ids)
    puts client_posts_ids
    @posts.select {|post| !client_posts_ids.find_index(post.id) } if client_posts_ids
  end
=end

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
      
      # use find_by_id so it does not throw exceptions
      entity = Entity.find_by_id(entity_id)
      unless entity
        logger.info("Post#index: Entity #{entity_id} does not exist")
        render :status => 400,
               :json => {:message => "Entity #{entity_id} does not exist." }
        return 
      end

      query_posts_for_entity entity

    elsif params[:type]
      type = params[:type]
      if type == "popular"
        @posts = Post.query_popular_posts(current_v1_user.id, @start_over, @last_of_previous_post_ids)
        
      elsif type == "friends"
        @posts = Post.query_friends_posts(current_v1_user.id, @start_over, @last_of_previous_post_ids)

      elsif type == "following"
        @posts = Post.query_following_posts(current_v1_user.id, @start_over, @last_of_previous_post_ids)

      elsif type == "my_posts"
        @posts = Post.query_my_posts(current_v1_user.id, @start_over, @last_of_previous_post_ids)
        
      elsif type == "posts_about_me"
        @posts = Post.query_posts_about_me(current_v1_user.id, @start_over, @last_of_previous_post_ids)

      else
        logger.info("Post#index: Wrong type of request: #{type}")
      end
    else
      logger.info("Post#index: Missing either entity_id or type in parameters")
    end

    #remove_client_matched_posts(params[:Post]) #@posts cannot be null!

    # @results = Array.new
    # TODO: Query in batch
    # this is bad because it queries the DB as many times as the number of posts
    # @posts.each_with_index {|post, i|
    #   @result = {
    #     :id => post.id,
    #     :uuid => post.uuid,
    #     :content => post.content,
    #     :updated_at => post.updated_at.to_f, #TODO: limit to 3-digit precision

    #     # meta attributes
    #     :is_yours => (current_v1_user.id == post.user_id), #TODO: compare current user and this user id
    #     :following => post.is_followed_by(current_v1_user.id),
    #     :popularity => post.popularity  
    #   }
      
      # association
      # this method checks the nullity of param[:Entity]
      # TODO: remove @results[i] from arguments since it is accessible in the method
      # add_entities_against_client_matched_entities(post, params[:Entity])
      # add_entities(post)

    #   @results << @result
    # }

    # @response = Hash.new
    # @response["Post"] = @results

    #puts @response
    #render json: @response 
    @user_id = current_v1_user.id # for view template's information
    render "posts/index"
  end

  # POST /posts/:id/follow
  def follow
    post_id = params[:post_id]
    unless post = Post.find_by_id(post_id)
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
    unless post = Post.find_by_id(post_id)
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
        json: {:message => "Can't destroy the follow of post #{post_id} and you"}
        return
      end
    else
      render status: 400, 
      json: {:message => "Follow of post #{post_id} and you does not exist."}
    end
  end

  # POST /posts/:id/report
  def report
    post_id = params[:post_id]
    unless post = Post.find_by_id(post_id)
      render :status => 400,
             :json => {:message => "Post #{post_id} does not exist." }
      return
    end

    if post.reports.create(user_id:current_v1_user.id)
      render status: 200, json: {}
    else
      render status: 422, json: {}
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
    
    render json: @posts

  end

  # DELETE /posts/1
  def destroy
    @post = Comment.find(params[:id])
    @post.status = false
    if @post.save
      render json:  @post
    end
  end
end
