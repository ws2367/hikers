class InstitutionsController < ApplicationController

  def create_institution_and_response inst_hash
    location = Location.find(inst_hash[:location_id])
    #TODO: check if location is deleted. If yes, send this info back to client or do nothing
    
    institution = location.institutions.new(:name => inst_hash["name"],
                                            :uuid => inst_hash["uuid"],
                                            :deleted => false)    
    response = Hash.new
    if institution.save
      response["id"] = institution.id
      response["uuid"] = institution.uuid
      response["updated_at"] = institution.updated_at.to_f 
    end

    return response
  end

  # POST /institutions
  def create
    if params["Institution"].class == Array
      @response = Array.new
      @response = params["Institution"].collect { |inst| create_institution_and_response inst}
      puts "Array!"
    else # if it is a single object
      @response = create_institution_and_response params["Institution"]
      puts "Not array!" + params["Institution"].class.to_s
    end

    puts @response
    respond_to do |format|
      format.json {render json: @response}
    end
  end

  # GET /institutions
  def index
    last_modified = params[:timestamp]

    @institutions = Institution.where("updated_at > ?", Time.at(last_modified.to_f).utc)
    
    @results = Array.new
    @institutions.each_with_index {|institution, i|
      @results[i] = Hash.new
      @results[i]["id"] = institution.id
      @results[i]["name"] = institution.name
      @results[i]["deleted"] = institution.deleted
      @results[i]["uuid"] = institution.uuid
      @results[i]["updated_at"] = institution.updated_at.to_f #TODO: limit to 3-digit precision
      @results[i]["location_id"] = institution.location.id
    }

    respond_to do |format|
       format.json { render json: @results }
     end
  end
end
