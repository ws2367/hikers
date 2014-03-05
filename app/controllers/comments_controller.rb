class CommentsController < ApplicationController

  respond_to :json
  
  @@salt = rand(1000000)

  # POST /comments
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(params[:comment])
    respond_to do |format|
    	if @comment.save
      		format.json { render json: @comment }
      end
    end
  end

  # TODO: Given the same user id and same post id, anonymized_user_id should return the same id
  # but it should also be impossible to guess the user id from knowing post ids
  # probably use a static salt that gets updated frequently here?
  def anonymize_user_id comment
    return comment.user_id + comment.post_id + @@salt
  end

  # GET /comments
  def index
    last_modified = params[:timestamp]

    @comments = Comment.where("updated_at > ?", Time.at(last_modified.to_i).utc)
    
    @results = Array.new
    @comments.each_with_index {|comment, i|
      @results[i] = Hash.new
      @results[i]["id"] = comment.id
      @results[i]["content"] = comment.content
      @results[i]["deleted"] = comment.deleted
      @results[i]["uuid"] = comment.uuid
      @results[i]["anonymized_user_id"] = anonymize_user_id comment
      @results[i]["updated_at"] = comment.updated_at.to_f #TODO: limit to 3-digit precision
      @results[i]["post_id"] = comment.post.id
    }

    respond_to do |format|
       format.json { render json: @results }
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
