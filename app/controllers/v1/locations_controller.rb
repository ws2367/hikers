class V1::LocationsController < ApplicationController

  respond_to :json

  #location /locations
  def create
    respond_to do |format|
      format.json { render status: :ok}
    end
  end

  # GET /locations/1
  def show
    @location = Location.find(params[:id])
    respond_to do |format|
          format.json { render json: @location }
    end
  end

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
