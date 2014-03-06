class CommentsController < ApplicationController

  respond_to :json
  
  @@salt = rand(1000000)
  
  puts "Salt= " + @@salt.to_s

  # TODO: Given the same user id and same post id, anonymized_user_id should return the same id
  # but it should also be impossible to guess the user id from knowing post ids
  # probably use a static salt that gets updated frequently here?
  def anonymize_user_id comment
    return comment.user_id + comment.post_id + @@salt
  end

  # POST /comments
  def create
    @post = Post.find(params["Comment"][:post_id])
    #TODO: check if @post is deleted. If yes, send this info back to client or do nothing
    
    #TODO: set user_id to current_user.id
    @comment = @post.comments.new(:content => params["Comment"]["content"],
                                  :uuid => params["Comment"]["uuid"],
                                  :deleted => false)

    #TODO: remove after setting it to current_user.id
    @comment.user_id = 1
    
    if @comment.save
      @response = Hash.new
      @response["id"] = @comment.id
      @response["uuid"] = @comment.uuid
      @response["anonymized_user_id"] = anonymize_user_id @comment
      @response["updated_at"] = @comment.updated_at.to_f 
      respond_to do |format|
        format.json {render json: @response}
      end
    end
  end


  # GET /comments or GET /posts/:id/comments
  def index
    if params[:post_id]
      post_id = params[:post_id]
      if post = Post.find(post_id) 
        @comments = post.comments
      else
        #TODO: error message back to server
      end
    else
      if params[:timestamp]
        last_modified = params[:timestamp]
      else
        last_modified = 0.0
      end
      @comments = Comment.where("updated_at > ?", Time.at(last_modified.to_f).utc)
    end

    # Mapping and Response Descriptor
    @response = Array.new
    @comments.each_with_index {|comment, i|
      @response[i] = Hash.new
      @response[i]["id"] = comment.id
      @response[i]["content"] = comment.content
      @response[i]["deleted"] = comment.deleted
      @response[i]["uuid"] = comment.uuid
      @response[i]["anonymized_user_id"] = anonymize_user_id comment
      @response[i]["updated_at"] = comment.updated_at.to_f #TODO: limit to 3-digit precision
      @response[i]["post_id"] = comment.post.id
    }

    respond_to do |format|
       format.json { render json: @response }
     end
  end

  # GET /comments/1
  def show
  	@comment = Comment.find(params[:id])
  	respond_to do |format|
      		format.json { render json: @comment }
    end
  end

  # DELETE /comments/1
  def destroy
    @comment = Comment.find(params[:id])
  	@comment.status = false
  	#@user.save!
  	respond_to do |format|
      if @comment.save
      	format.json { render json:  @comment}
      end
    end
  end
end
