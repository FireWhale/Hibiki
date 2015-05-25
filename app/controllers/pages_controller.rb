class PagesController < ApplicationController
    
  def front_page
    authorize! :read, Album
    
    @posts = Post.with_category("Blog Post").meets_security(current_user).order(:id => :desc).includes(:tags).first(5)
    @albums = Album.filter_by_user_settings(current_user).order("RAND()").includes(:primary_images, :translations).first(8).shuffle
    
    respond_to do |format|
      format.html
    end
  end

  def help
    authorize! :read, Album
    
    respond_to do |format|
      format.html
    end
  end
  
  def calendar
    authorize! :read, Album
    
    respond_to do |format|
      format.html
    end
  end
  
  def random_albums #Just a fun side-project to display   
    authorize! :read, Album
    
    album_count = [(params[:count] || 100).to_i, 250].min #a maximum of 250 albums will be allowed
    @albums = Album.filter_by_user_settings(current_user).order("RAND()").includes(:primary_images).first(album_count).shuffle
    @slice = (@albums.count / 6.0).ceil
    
    respond_to do |format|
      format.html
      format.json { render json: @albums.to_json(:user => current_user)}
    end
  end  
   
  def search
    authorize! :read, Album
    @query = truncate(params[:search], length: 50, escape: false) #used in html
    @model = (params[:model].nil? ? nil : params[:model]) #for JS
    @records = nil
    @search = {:utf8 => params[:utf8], :search => @query} #used
    
    respond_to do |format|
      format.html { @models = ["album", "artist", "source", "organization", "song"]}
      format.js { @models = (@model.nil? ? ["album", "artist", "source", "organization", "song"] : [@model])}
    end
    
    @models.each do |model|
      #set up eager loading hash
      includes = [:tags, :translations]
      if model == "artist" || model == "organization" || model == "source"
        includes.push(:watchlists)
        #don't include albums. we only need the first 5 of them + count
      elsif model == "song"
        includes.push(album: [:primary_images, :translations])
      elsif model == "album"
        includes.push(:primary_images)
      end
      search = model.capitalize.constantize.search(:include => includes) do
        any do
          fulltext params[:search] do
            if model == "album"
              fields(:internal_name, :synonyms, :namehash, :translated_names, :reference, :catalog_number)          
            else
              fields(:internal_name, :synonyms, :namehash, :translated_names, :reference)
            end
          end      
          if params[:search].include?("*")
            fulltext "\"#{params[:search]}\"" do
              if model == "album"
                fields(:internal_name, :synonyms, :namehash, :translated_names, :reference, :catalog_number)          
              else
                fields(:internal_name, :synonyms, :namehash, :translated_names, :reference)
              end
            end      
            
          end    
        end
        order_by(:release_date) if model == "album"
        paginate :page => params["#{model}_page".to_sym]
      end      
      instance_variable_set("@#{model}_count", search.total)
      if search.total > 0 && @model.nil?
        @model = model
      end
      @records = search.results if @model == model && @records.nil? 
    end
    @model = "any cateogorie" if @model.nil? #text for if there were no results at all
  end 
   
  def forgotten_password
    authorize! :forgotten_password, User
    
    respond_to do |format|
      format.html
    end
  end
  
  
  def request_password_reset_email
    authorize! :request_password_reset_email, User
    
    @user = User.find_by_email(params[:email])
    @user.deliver_password_reset_instructions! unless @user.nil?
    
    respond_to do |format|
      #Reusing the forgotten_password_path so I don't have to add a route and controller method
      format.html { redirect_to forgotten_password_path, notice: "Thank you! An email has been sent to #{truncate(params[:email], length: 50)} with instructions to recover your password. If you do not receive an email, please contact support."  }
      format.json { head :no_content }
    end 
  end
  
  def reset_password_page
    authorize! :reset_password_page, User
    @token = params[:token]
    @user = User.find_using_perishable_token(@token)
    
    respond_to do |format|
      format.html
    end
  end
  
  def reset_password
    authorize! :reset_password, User
    @user = User.find_using_perishable_token(params[:user][:token])
  
    unless @user.nil?
      #I'm probably fixing this the wrong way, but:
      @user.password = "invalid"
      @user.valid?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @token = params[:user][:token]
    end
    
    respond_to do |format|
      if @user.nil? #Not a valid token
        format.html { redirect_to :root }
        format.json { render json: {}, status: :unprocessable_entity }
      else
        if @user.save
          format.html { redirect_to :root }
          format.json { head :no_content }
        else
          format.html { render action: 'reset_password_page', notice: 'Failed to reset password' }
          format.json { render json: @user.errors.to_hash.except!(:crypted_password, :password_salt), status: :unprocessable_entity }
        end        
      end
    end 
  end

end
