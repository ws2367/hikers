# Rails.root/app/controllers/sessions.rb

class SessionsController < Devise::SessionsController
  def create
    logger.info "Attempt to sign in by #{ params[:user][:user_name] }"
    super
  end

  def destroy
    logger.info "#{ current_user.user_name } signed out"
    super
  end
end
