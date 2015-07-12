class UsersController < ApplicationController
  load_and_authorize_resource
  layout "grid", only: [:watchlist]
  
  def collect
    user = current_user
    @record = params[:record_type].constantize.find_by_id(params[:record_id])
    unless user.nil? || @record.nil? || params[:relationship].nil?
      @collection = user.collections.create(collected_id: @record.id, collected_type: @record.class.to_s, :relationship => params[:relationship])
    end
    
    respond_to do |format|
      unless @collection.nil? #failed to make a collection
        format.html { redirect_to @record, notice: "Successfully added to collection!" }
        format.js        
      else
        format.html { redirect_to @record, notice: "Failed to add to collection :<" }
        format.js        
      end

    end
  end
  
  def watch
    user = current_user
    @watched = params[:watched_type].constantize.find(params[:watched_id])
    unless user.nil? || @watched.nil?
      @watchlist = user.watchlists.create(:watched_type => @watched.class.to_s, :watched_id => @watched.id)
    end

    respond_to do |format| 
      unless @watchlist.nil?
        format.html { redirect_to @watched, notice: 'Successfully added to watchlist' }
        format.js
      else
        format.html { redirect_to @watched, notice: 'Failed to add to watchlist' }
        format.js
      end
    end
  end
  
  def uncollect
    @record = params[:record_type].constantize.find_by_id(params[:record_id])
    collection = Collection.where(user: current_user, collected: @record).first
    collection.destroy unless collection.nil?
    
    respond_to do |format|
      format.html { redirect_to @record, notice: 'Successfully removed!' }
      format.js
    end
  end
  
  def unwatch    
    @watched = params[:watched_type].constantize.find_by_id(params[:watched_id])

    watchlist = Watchlist.where(user: current_user, watched: @watched).first
    watchlist.destroy unless watchlist.nil?
    
    respond_to do |format|        
      format.html { redirect_to @watched, notice: 'Successfully removed from watchlist' }
      format.js
    end
  end
  
  def index
    @users = User.order(:id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.privacy_settings.include?("Show Profile") || @user == current_user
        format.html # show.html.erb
        format.json { render json: @user }
      else
        format.html { render 'private_page'}
        format.json { head :forbidden }
      end
    end
  end

  def overview
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html # overview.html.erb
      format.json { render json: @user }
    end
  end

  def watchlist
    #Using albums instead of the albumartist/albumorg/albumsource because well, it's simpler code
    @user = User.includes(:watchlists => [{:watched => [:translations]}]).find(params[:id])
    
    #group, format, and sort what the user is watching
    @watched = @user.watchlists.group_by(&:grouping_category)
    @watched.each do |k,v|
      @watched[k].sort_by! {|a| language_helper(a.watched, :name, highlight: false).downcase}
      @watched[k].sort_by! {|a| a.position || 100000 }      
      @watched[k] = v.map(&:watched)
    end  

    respond_to do |format|
      if @user.privacy_settings.include?("Show Watchlist") || @user == current_user
        format.html # watchlist.html.erb
        format.json { render json: @user.watchlists.map(&:watched).to_json(:user => current_user) }
      else
        format.html { render 'private_page'}
        format.json { head :forbidden }        
      end
    end
  end
    
  def collection
    @user = User.find(params[:id])
    
    #Get albums
      collected_albums = Album.in_collection(@user.id, "Collected").includes(:primary_images, :tags, :translations)
      ignored_albums = Album.in_collection(@user.id, "Ignored").includes(:primary_images, :tags, :translations)
      wishlisted_albums = Album.in_collection(@user.id, "Wishlisted").includes(:primary_images, :tags, :translations)
    
    #get songs
      collected_songs = Song.in_collection(@user.id, "Collected").includes(:primary_images, :tags, :translations)
      ignored_songs = Song.in_collection(@user.id, "Ignored").includes(:primary_images, :tags, :translations)
      wishlisted_songs = Song.in_collection(@user.id, "Wishlisted").includes(:primary_images, :tags, :translations)
      
    #combine the two and sort by release date
      @collected = (collected_albums + collected_songs).sort_by {|a| a.release_date ? a.release_date : Date.new }.reverse!
      @ignored = (ignored_albums + ignored_songs).sort_by {|a| a.release_date ? a.release_date : Date.new }.reverse!
      @wishlisted = (wishlisted_albums + wishlisted_songs).sort_by {|a| a.release_date ? a.release_date : Date.new }.reverse!
      
    #get counts
      @collected_count = @collected.count
      @ignored_count = @ignored.count
      @wishlisted_count = @wishlisted.count
    
    @type = params[:type]
    
    if @type.nil? || ["collected", "ignored", "wishlisted"].include?(@type) == false
      @records = Kaminari.paginate_array(@collected).page(params[:page]).per(30)
      @type = "collected"
    else
      @records = Kaminari.paginate_array(instance_variable_get("@#{@type}")).page(params[:page]).per(30)
    end
          
    respond_to do |format|
      if @user.privacy_settings.include?("Show Collection") || @user == current_user
        format.html
        format.json {render json: @user.collections.map(&:collected).to_json(:user => current_user)}
        format.js
      else
        format.html { render 'private_page'}
        format.json { head :forbidden }
        format.js {head :forbidden}   
      end
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit_security
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html # edit_security.html.erb
      format.json { render json: @user }
    end
  end

  def edit_profile
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # edit_security.html.erb
      format.json { render json: @user }      
    end
  end
  
  def edit_watchlist
    @user = User.includes({watchlists: {watched: :translations}}).find(params[:id])
    
    @watched = @user.watchlists.group_by(&:grouping_category)    
    @watched.each do |k,v|
      @watched[k].sort_by! {|a| language_helper(a.watched, :name, highlight: false).downcase}
      @watched[k].sort_by! {|a| a.position || 100000 }      
    end      
    @watched = @watched.sort_by { |k,v| (k ||= "").downcase}
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end    
  end
  
  def create
    @user = User.new(params[:user])
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to({action: 'edit_profile', id: @user.id }, notice: "Welcome to Hibiki! I highly recommend adjusting these settings to your preferences.")}
        format.json { render json: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_security
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.update_security(params[:user])
        format.html { redirect_to({action: 'overview', id: @user.id}, notice: 'Security was successfully updated.')}
        format.json { head :no_content }
      else
        format.html { render action: "edit_security" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  def update_profile
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user == current_user
        if @user.update_profile(params[:user])    
          format.html { redirect_to edit_profile_user_path(:id => params[:id]), notice: 'Profile was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit_profile" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else
        format.html { render "pages/access_denied" }
        format.json { head :forbidden }
      end
    end
  end
  
  def update_watchlist
    @user = User.find(params[:id])
    #Grab the new list of where each watched goes
    
    watchlists = params[:watchlists]
    unless watchlists.nil? || @user != current_user
      watchlists.deep_symbolize_keys.each do |grouping, values|
        unless grouping.nil? || grouping.empty? || values[:records].nil?
          values[:records].each do |id|
            watchlist = Watchlist.find_by_id(id)
            unless watchlist.nil? || values[:name].nil?
              watchlist.grouping_category = values[:name].truncate(40)
              watchlist.save
            end
          end
        end
      end
      success = true
    else
      success = false
    end

    respond_to do |format|
      if @user == current_user
        if success #if all watchlists pass
          format.html { redirect_to edit_watchlist_user_path(:id => params[:id]), notice: 'Watchlist was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit_watchlist" }
          format.json { render json: @user.errors, status: :unprocessable_entity }          
        end
      else
        format.html { render "pages/access_denied" }
        format.json { head :forbidden }
      end
    end        
  end  

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def add_grouping
    respond_to do |format|
      format.js
    end
  end
    
  private
    def edit_profile_helper(setting, hash, text, symbol)
      #Used in edit_profile
      if setting.include?(text)
        hash[symbol] = text
      else
        hash[symbol] = ''
      end      
    end
end
