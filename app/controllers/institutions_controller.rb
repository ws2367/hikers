class InstitutionsController < ApplicationController

  # GET /institutions
  def index
    last_modified = params[:timestamp]

    @institutions = Institution.where("updated_at > ?", Time.at(last_modified.to_i).utc)
    
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
