class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :after_token_authentication # it is empty hook provided by devise i,e 
  # once user is successfully authenticated with the token devise look for this method, 
  # and execute the code there

  def after_token_authentication
    if params[:authentication_key].present?
      @user = User.find_by_authentication_token(params[:authentication_key]) # we are finding 
      # the user with the authentication_key with which devise has authenticated the user
      sign_in @user if @user # we are siging in user if it exist. sign_in is devise method to sigin in any user
                               
      redirect_to root_path # now we are redirecting the user to root_path i,e our home page
    end
  end
end
