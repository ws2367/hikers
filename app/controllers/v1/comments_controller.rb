class V1::CommentsController < ApplicationController

  before_filter :authenticate_v1_user!

   
  # TODO: Given the same user id and same post id, anonymized_user_id should return the same id
  # but it should also be impossible to guess the user id from knowing post ids
  # probably use a static salt that gets updated frequently here?
  def anonymize_user_id comment
    return comment.user_id + comment.post_id
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
        puts "Notification is sent to user #{follower.name}"
        apn.push(notification)  

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
                                  :user_id => current_v1_user.id)

    puts "Comment's user id: " + @comment.user.id.to_s


    if @comment.save
      #send out notification!
      send_push_notification @comment

      @response = Hash.new
      @response["id"] = @comment.id
      @response["uuid"] = @comment.uuid
      @response["anonymized_user_id"] = anonymize_user_id @comment
      @response["updated_at"] = @comment.updated_at.to_f 
      
      puts @response
      render json: @response
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

    # Mapping and Response Descriptor
    @response = Hash.new

    comment_response = Array.new
    @comments.each_with_index {|comment, i|
      comment_response[i] = {
        :id => comment.id,
        :uuid => comment.uuid,
        :content => comment.content,
        :updated_at => comment.updated_at.to_f, #TODO: limit to 3-digit precision

        #meta attributes
        :anonymized_user_id => anonymize_user_id(comment),

        :post_uuid => comment.post.uuid
      }
    }    

    @response["Comment"] = comment_response
    #@response["Institution"] = institution_response if institution_response.count > 0    

    puts @response
    render json: @response
  end

 end
