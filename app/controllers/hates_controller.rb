class HatesController < ApplicationController

  respond_to :json
  

  # POST /likes
  def create
    @user = User.find(params[:user_id])
    @hateContent = params[:hate]
    @hate = @user.hates.new(@hateContent)
    puts @hateContent
    if @hateContent[:hatee_type] == "Post"
      puts "into if Post"
      @post = Post.find(@hateContent[:hatee_id])
      puts "post"
      puts @post.content
      puts "post haters num"
      puts @post.hatersNum 
      #@post.hatersNum += 1
    end

    respond_to do |format|
    	if @hate.save
      		format.json { render json: @hate }
      end
    end
  end


  # DELETE /hates/1
  def destroy
  	@hate = Hate.find(params[:id])
    @hate.destroy
  	respond_to do |format|
      	format.json { render json:  @hate}
    end
  end
end
