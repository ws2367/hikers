class V1::InvitationsController < ApplicationController
  
  before_filter :authenticate_v1_user!

  # POST /inviter
  def inviter

    invitation = Invitation.new(inviter_name: params["name"], 
                                inviter_birthday: params["birthday"],
                                inviter_fb_id: params["fb_id"],
                                user_id: current_v1_user.id)
                    
    if invitation.save
      render :status => 200, :json => {}
    else
      render :status => 422,
             :json => {:message => "Can't save the invitation" }
    end
  end


end
