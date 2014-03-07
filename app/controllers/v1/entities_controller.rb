class V1::EntitiesController < ApplicationController

  respond_to :json

  def create_entity_and_response entity_hash
    institution = Institution.find_by_uuid(entity_hash[:institution_uuid])
    #TODO: check if @institution is deleted. If yes, send this info back to client or do nothing
    
    entity = institution.entities.new(:name => entity_hash["name"],
                                       :uuid => entity_hash["uuid"])
    subresponse = Hash.new
    if entity.save
      subresponse["id"] = entity.id
      subresponse["uuid"] = entity.uuid
      subresponse["updated_at"] = entity.updated_at.to_f 
    end

    return subresponse
  end

  # POST /entities
  def create
    if params["Entity"].class == Array
      @response = Array.new
      @response = params["Entity"].collect { |ent| create_entity_and_response ent}
    else # if it is a single object
      @response = create_entity_and_response params["Entity"]
    end

    puts @response
    respond_to do |format|
      format.json {render json: @response}
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

    @entities = Entity.where("updated_at > ?", Time.at(last_modified.to_f).utc)
    
    @results = Array.new
    @entities.each_with_index {|entity, i|
      @results[i] = Hash.new
      @results[i]["id"] = entity.id
      @results[i]["name"] = entity.name
      @results[i]["updated_at"] = entity.updated_at.to_f #TODO: limit to 3-digit precision
      #@results[i]["deleted"] = entity.deleted #TODO: probably add deleted field to DB??
      @results[i]["uuid"] = entity.uuid
      @results[i]["institution_uuid"] = entity.institution.uuid
    }

    respond_to do |format|
       format.json { render json: @results }
     end
  end

  # PUT /entities/1
  def update
  end
end
