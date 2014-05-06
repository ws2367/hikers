class V1::CommentsController < ApplicationController

  before_filter :authenticate_v1_user!

   
  MAX_INDEX_OF_ANONYMIZED_USER_ID = 29

  def anonymize_user_id(post, user_id)
    # if the user has commented before...
    existing_user_ids = post.comments.collect{|comment| [comment.user_id, comment.anonymized_user_id]}
    index = existing_user_ids.find_index{|pair| pair[0] == user_id}
    if index
      return existing_user_ids[index][1]
    else 
    # if the user has not commented before...
      used_anonymized_user_ids = post.comments.collect{|comment| comment.anonymized_user_id}
      available_anonymized_user_ids = (1..MAX_INDEX_OF_ANONYMIZED_USER_ID).to_a - used_anonymized_user_ids
      result = available_anonymized_user_ids.sample
      # if all possible ids are used.... then we have to randomly pick up one
      if result == nil
        result = (1..MAX_INDEX_OF_ANONYMIZED_USER_ID).sample
        logger.info("[ERROR] Post #{post.id} has too many commenters! Supply with more comment icons.")
      end
      return result
    end
  end

  #TODO: this should be done in the background
  def send_push_notification comment
    comment_author = comment.user
    # notify the author of the post
    post_author = comment.post.user
    # check if the author of the post is the same as the author of the comment
    # and whether the device token is set
    if ((post_author.id != comment_author.id) and 
        (post_author.device_token != nil)
       )

      # increment their badge numbers
      post_author.update_attribute("badge_number", (post_author.badge_number + 1))
      # send out notification
      apn = Houston::Client.development
      apn.certificate = File.read("config/apple_push_notification.pem")
      notification = Houston::Notification.new(device: post_author.device_token)
      notification.alert = "Someone wrote a comment on your post!"
      notification.badge = post_author.badge_number
      notification.content_available = true
      notification.custom_data = {post_id: comment.post.id}

      apn.push(notification)  
      puts "Notification is sent to user #{post_author.name}"
    end
    
    # notify the followers of the post
    followers = comment.post.followers
    followers.each do |follower|
      if ((follower.id != comment_author.id) and 
          (follower.device_token != nil)
         )

        # increment their badge numbers
        follower.update_attribute("badge_number", (follower.badge_number + 1))
        # send out notification
        apn = Houston::Client.development
        apn.certificate = File.read("config/apple_push_notification.pem")
        notification = Houston::Notification.new(device: follower.device_token)
        notification.alert = "Someone wrote a comment on the post you favorited!"
        notification.badge = follower.badge_number
        notification.content_available = true
        notification.custom_data = {post_id: comment.post.id}

        apn.push(notification)  
        puts "Notification is sent to user #{follower.name}"
      end
    end

    # notify the entities of the post of the comment
    users = User.users_as_entities_of_post(comment.post)
    comment_author = comment.user
    logger.info("#{users.count} users referred in the post are found. Will try to send notification to them")
    # notify the entities of the post
    users.each do |user|
      if ((user.id != comment_author.id) and 
          (user.device_token != nil)
         )

        # increment their badge numbers
        user.update_attribute("badge_number", (user.badge_number + 1))
        # send out notification
        apn = Houston::Client.development
        apn.certificate = File.read("config/apple_push_notification.pem")
        notification = Houston::Notification.new(device: user.device_token)
        notification.alert = "Someone wrote a comment on a post about you!"
        notification.badge = user.badge_number
        notification.content_available = true
        notification.custom_data = {post_id: comment.post.id}
        
        #puts "Notification is sent to user #{user.name}"
        apn.push(notification)  
      end
    end
  end

  # POST /comments
  def create
    @post = Post.find_by_uuid(params["Comment"][:post_uuid])
    #TODO: check if @post is deleted. If yes, send this info back to client or do nothing
    
    @comment = @post.comments.new(:content => params["Comment"]["content"],
                                  :uuid => params["Comment"]["uuid"],
                                  :deleted => false,
                                  :user_id => current_v1_user.id,
                                  :anonymized_user_id => anonymize_user_id(@post, current_v1_user.id))

    if @comment.save
      #send out notification!
      send_push_notification @comment

      render 'comments/create'
    end
  end


  # GET /comments or GET /posts/:id/comments
  def index
    if params[:post_id]
      post_id = params[:post_id]
      if post = Post.find(post_id) 
        @comments = post.comments
      else
        # Post does not exist!
        render :status => 400,
               :json => {:message => "Post #{post_id} does not exist." }
        return
      end
    else #TODO: kill this part or improve it
      if params[:timestamp]
        last_modified = params[:timestamp]
      else
        last_modified = 0.0
      end
      @comments = Comment.where("updated_at > ?", Time.at(last_modified.to_f).utc)
    end

    render "comments/index"
  end

 end
