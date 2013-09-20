class LikesController < ApplicationController

  respond_to :json
  

  # POST /likes
  def create
    @user = User.find(params[:user_id])
    @likeContent = params[:like]
    @like = @user.likes.new(@likeContent)
    if @likeContent[:likee_type] == "Post"
      @post = Post.find(@likeContent[:likee_id])
      #@post.likersNum += 1
    end
    respond_to do |format|
    	if @like.save
      		format.json { render json: @like }
      end
    end
  end

  # DELETE /likes/1
  def destroy
    @like = Like.find(params[:id])
    @like.destroy
    respond_to do |format|
        format.json { render json:  @like}
    end
  end
end
