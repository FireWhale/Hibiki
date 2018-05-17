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
    @user_session = UserSession.new(user_session_params)
    
    respond_to do |format|
      if @user_session.save
        format.html {redirect_to root_path}
        format.json { head :no_content }
      else
        format.html { render action: 'new'}
        format.json { render json: {:success => false, :message => "Invalid username or password"}, status: :unprocessable_entity }
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

  def user_session_params
    params.require(:user_session).permit!.to_h
  end

end
