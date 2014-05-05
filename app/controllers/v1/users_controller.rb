class V1::UsersController < ApplicationController

  before_filter :authenticate_v1_user!

  # POST users/set_badge
  def set_badge
    badge_number = params["badge_number"]
    if current_v1_user.update_attribute("badge_number", badge_number)
      puts "User #{current_v1_user.id}'s badge number is changed to #{badge_number}."
      render :status=>200, :json=>{}
    else
      render :status=>422, 
             :json=>{message: "Internal server error. Failed to save badge number." }
    end
  end

  # POST users/set_device_token
  def set_device_token
    device_token = params[:device_token]
    puts "device token: %s" % device_token
    
    current_v1_user.update_attribute("device_token", device_token)
  end
end
