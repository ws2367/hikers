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
  	name = params[:name]
  	@entities = Entity.where(name: name).limit(params[:num])
  	respond_to do |format|
       format.json { render json: @entities }
    end
  end

  # PUT /entities/1
  def update
  end
end
