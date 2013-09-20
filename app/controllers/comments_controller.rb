class CommentsController < ApplicationController

  respond_to :json
  

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
