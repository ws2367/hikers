class V1::PostsController < ApplicationController
  
  before_filter :authenticate_v1_user!

  #TODO: this should be done in the background
  def send_push_notification post
    # notify the entities of the post
    users = User.users_as_entities_of_post(post)
    post_author = post.user
    logger.info("#{users.count} users referred in the post are found. Will try to send notification to them")
    # notify the entities of the post
    users.each do |user|
      if ((user.id != post_author.id) and 
          (user.device_token != nil)
         )

        # increment their badge numbers
        user.update_attribute("badge_number", (user.badge_number + 1))
        # send out notification
        apn = Houston::Client.development
        apn.certificate = File.read("config/apple_push_notification.pem")
        notification = Houston::Notification.new(device: user.device_token)
        notification.alert = "Someone wrote a post about you!"
        notification.badge = user.badge_number

        notification.content_available = true
        notification.custom_data = {post_id: post.id}
        #logger.info "Notification is sent to user #{user.name}"
        apn.push(notification)  
      end
    end
  end

  def map_an_entity hash
    # In a request, the fb_user_id should not be 0 or nil.
    # It sends back id, fb_user_id and updated_at. 
    entity = nil
    # Note that nil.to_i = 0
    if hash["fb_user_id"].to_i != 0
      entity = Entity.find_by_fb_user_id(hash["fb_user_id"].to_i)
      if entity # if the entity exists
        return entity 
      else # if the entity does not exist
        entity = Entity.new(name: hash["name"],
                            fb_user_id: hash["fb_user_id"].to_i,
                            user_id: current_v1_user.id)

        entity.institution = hash["institution"] if hash["institution"]
        entity.location = hash["location"] if hash["location"]
        
        if entity.save
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
    # logger.info params
    
    entitiesToMap = params["Entity"]
    if entitiesToMap
      if entitiesToMap.class == Array
        @entities = entitiesToMap.collect {|entity| map_an_entity entity}
      else
        @entities = [map_an_entity(entitiesToMap)] # make sure it is an array
      end
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

    render "posts/create"
  end

  def query_posts_for_entity entity
    query_result = entity.posts.active.order("updated_at desc")
    if @start_over
      @posts = query_result.limit(5)
    else
      start_index = query_result.index{|post| post.id == @last_of_previous_post_ids.to_i}
      if start_index 
        start_index += 1
        count = query_result.count
        end_index = [(start_index + 4), (count - 1)].min
        @posts = query_result.slice(start_index..end_index) 
      else
        @posts = Array.new
      end
    end
  end

  # GET /posts or GET /entities/:id/posts
  def index    
    @posts = Array.new #prevent @posts from being null

    # if it just wants a single post
    if params[:post_id]
      post_id = params[:post_id]
      post = Post.find_by_id(post_id)
      unless post
        render :status => 400,
               :json => {:message => "Post #{post_id} does not exist." }
        return
      end

      @posts << post
      @user_id = current_v1_user.id # for view template's information
      render 'posts/index'
      return # we've done the business here
    end

    @start_over = false
    if params[:last_of_previous_post_ids]
      @last_of_previous_post_ids = params[:last_of_previous_post_ids]
    else
      @start_over = true
      logger.info "Start over"
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

  # POST /posts/:post_id/report
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


  # POST /posts/:post_id/share
  def share 
    logger.info params
    post_id = params[:post_id]
    unless post = Post.find_by_id(post_id)
      render :status => 400,
             :json => {:message => "Post #{post_id} does not exist." }
      return
    end

    share = post.shares.new(user_id: current_v1_user.id)

    numbers = params["numbers"]

    if numbers.class == Array
      numbers.each do |number|
        share.add_number(number.to_i)
      end
    else
      share.add_number(numbers.to_i)
    end

    if share.save
      render :status => 200, :json => {}
    else
      render :status => 422,
             :json => {:message => "Can't save the share" }
    end
  end

  # POST /posts/:post_id/activate
  def activate
    #TODO: maybe confirm the creator is the user who sent the POST request?
    post_id = params[:post_id]
    unless post = Post.find_by_id(post_id)
      render :status => 400,
             :json => {:message => "Post #{post_id} does not exist." }
      return
    end

    post.is_active = true
    if post.save
      send_push_notification post
      render :status => 200, :json => {}
    else
      render :status => 422,
             :json => {:message => "Can't save the post" }
    end
  end

  # POST /searchposts
  # def search
  #   keyword = params[:keyword]
  #   num = params[:num]
  #   searchby = params[:searchby]
  #   if searchby == "location"
  #     @location = Location.where(name: keyword).limit(3)
      
  #     @posts = Post.where(name: name).limit(params[:num])
  #   elsif searchby == "content"
  #     @substring = '%' + keyword + '%'
  #     @posts = Post.where('content LIKE ?', @substring).limit(num)
  #   end
    
  #   render json: @posts

  # end

  # # DELETE /posts/1
  # def destroy
  #   @post = Comment.find(params[:id])
  #   @post.status = false
  #   if @post.save
  #     render json:  @post
  #   end
  # end
end
