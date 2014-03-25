class V1::LocationsController < ApplicationController

  respond_to :json
  # before_filter :authenticate_v1_user!
  
  
  # GET /locations
  def index
    last_modified = params[:timestamp]

    @locations = Location.where("updated_at > ?", Time.at(last_modified.to_i).utc)
    
    @results = Array.new
    @locations.each_with_index {|location, i|
      @results[i] = Hash.new
      @results[i]["id"] = location.id
      @results[i]["name"] = location.name
      @results[i]["updated_at"] = location.updated_at.to_f #TODO: limit to 3-digit precision
    }

    respond_to do |format|
       format.json { render json: @results }
    end
  end
end
