class UserSessionsController < ApplicationController
  load_and_authorize_resource
  
  def new
    @user_session = UserSession.new
    
    respond_to do |format|
      format.html
      format.json { render json: @user_session }
    end
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    
    respond_to do |format|
      if @user_session.save
        format.html {redirect_to root_path}
        format.json { head :no_content }
      else
        format.html { render action: 'new'}
        format.json { render json: @user_session.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    
    respond_to do |format|
      format.html {redirect_to root_path}
      format.json { head :no_content }
    end
  end
end
