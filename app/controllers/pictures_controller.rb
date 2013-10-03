class PicturesController < ApplicationController

  respond_to :json

  # Test: curl -X POST -H "Content-Type: image/jpeg" --data-binary @test.jpg http://localhost:3000/pictures/1000
  # POST /pictures/:post_id
  def create
  	# using create(..), if it cannot be saved in db, id is nil
     
  	@pic = Picture.create(post_id: params[:post_id].to_i, 
  		                  img: request.body, img_content_type: request.content_type)
  	
  	# Picture model validates whether the assoicated post exists
	respond_to do |format|
		format.json { render json: { "status" => @pic.id? ? "success" : "fail", "index" => "#{@pic.post.pictures.index(@pic)}"} }
	end
  end

  #GET /pictures/:post_id/:index
  def show
  	@post = Post.find(params[:post_id].to_i)
    logger.info("Post id=#{@post.id} is found.")
  	@pic  = @post.pictures[params[:index].to_i]
  	logger.info("Picture id=#{@pic.id} is found.")
  	redirect_to @pic.img.url
  end

  def destroy
  end
end
