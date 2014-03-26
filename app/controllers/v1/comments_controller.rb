class V1::CommentsController < ApplicationController

  respond_to :json
  before_filter :authenticate_v1_user!

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
    @post = Post.find_by_uuid(params["Comment"][:post_uuid])
    #TODO: check if @post is deleted. If yes, send this info back to client or do nothing
    
    #TODO: set user_id to current_user.id
    @comment = @post.comments.new(:content => params["Comment"]["content"],
                                  :uuid => params["Comment"]["uuid"],
                                  :deleted => false,
                                  :user_id => current_v1_user.id)

    puts "Comment's user id: " + @comment.user.id.to_s

    if @comment.save
      @response = Hash.new
      @response["id"] = @comment.id
      @response["uuid"] = @comment.uuid
      @response["anonymized_user_id"] = anonymize_user_id @comment
      @response["updated_at"] = @comment.updated_at.to_f 
      
      puts @response
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
        :deleted => comment.deleted,
        :anonymized_user_id => anonymize_user_id(comment),

        :post_uuid => comment.post.uuid
      }
    }

    # prepare institution information
    institution_response = Array.new
    if params["Institution"]
      institution_ids = params["Institution"]
      
      insts = Array.new
      begin
        insts = Institution.find(institution_ids)
      rescue
        logger.info("Institution IDs #{institution_ids} cannot be found for each.")
      end
      
      institution_response = insts.collect{ |inst| 
        hash = {
          :id => inst.id,
          :uuid => inst.uuid,
          :name => inst.name,
          :deleted => inst.deleted,
          :updated_at => inst.updated_at
        } 
        hash[:location_id] = inst.location.id if inst.location
        hash 
      } if insts.count > 0
    end

    @response["Comment"] = comment_response
    @response["Institution"] = institution_response if institution_response.count > 0    

    puts @response
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
