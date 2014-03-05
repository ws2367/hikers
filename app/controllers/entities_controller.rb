class EntitiesController < ApplicationController

  respond_to :json

  # POST /entities
  def create
	#@entity = Entity.create!(    name: params[:name])
	#name = params[:name]
	#puts name
	@entity = Entity.new(params[:entity])
	@entity.likersNum = 0
	@entity.followersNum = 0
	@entity.hatersNum = 0
	@entity.viewersNum = 0
	#@entity.save!
    respond_to do |format|
    	if @entity.save
      		format.json { render json: @entity }
      	end
    end
  end

  # GET /entities/1
  def show
  	@entity = Entity.find(params[:id])
    respond_to do |format|
       format.json { render json: @entity }
    end
  end

  # GET /entities
  def index
    last_modified = params[:timestamp]

    @entities = Entity.where("updated_at > ?", Time.at(last_modified.to_i).utc)
    
    @results = Array.new
    @entities.each_with_index {|entity, i|
      @results[i] = Hash.new
      @results[i]["id"] = entity.id
      @results[i]["name"] = entity.name
      @results[i]["updated_at"] = entity.updated_at.to_f #TODO: limit to 3-digit precision
      #@results[i]["deleted"] = entity.deleted #TODO: probably add deleted field to DB??
      @results[i]["uuid"] = entity.uuid
      @results[i]["institution_id"] = entity.institution.id
    }

    respond_to do |format|
       format.json { render json: @results }
     end
  end

  # PUT /entities/1
  def update
  end
end
