class UsersController < ApplicationController
  load_and_authorize_resource
  
  def watch
    @user = current_user
    
    @user.watchlists.create(:watched_type => params[:watched_type], :watched_id => params[:watched_id])
    @watched = params[:watched_type].constantize.find(params[:watched_id])
    respond_to do |format| 
      format.html { redirect_to @watched, notice: 'Successfully added to watchlist' }
      format.js
    end
  end
  
  def unwatch
    watchlist = Watchlist.where(:user_id => current_user.id, :watched_id => params[:watched_id], :watched_type => params[:watched_type]).first
    watched = params[:watched_type].constantize.find(params[:watched_id])

    respond_to do |format|
      if watchlist.nil? == false
        watchlist.destroy
        format.html { redirect_to watched, notice: 'Successfully removed from watchlist' }
        format.js
      else
        format.html { redirect_to watched, notice: 'Request failed!' }
        format.js        
      end
    end
  end

  def add_to_collection
    user = current_user
    @album = Album.find(params[:album_id])
    if user.nil? == false && @album.nil? == false
      user.collections.create(:album_id => @album.id, :relationship => params[:relationship])
    end
    
    #Formating response text
    if params[:relationship] == "Collected"
      @text = "Added!"
      @noticetext = 'added to collection'
    elsif params[:relationship] == "Ignored"
      @text = "Ignored!"
      @noticetext = 'added to ignore list' 
    elsif params[:relationship] == "Wishlist"
      @text = "Added!"
      @noticetext = 'added to wishlist' 
    end

    respond_to do |format|
      format.html { redirect_to @album, notice: "Successfully " + @noticetext }
      format.js
    end
  end
  
  def uncollect
    collection = Collection.where(:user_id => params[:user_id], :album_id => params[:album_id]).first
    album = Album.find(params[:album_id])
    if collection.nil? == false
      collection.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to album, notice: 'Successfully removed!' }
      format.js
    end
  end

  def watchlist
    #Using albums instead of the albumartist/albumorg/albumsource because well, it's simpler code
    @user = User.includes({watchlists: {watched: :albums}}).find(params[:id])

    #group, format, and sort what the user is watching
      @watched = @user.watchlists.group_by(&:grouping_category)
      @watched.each do |k,v|
        @watched[k].sort_by! {|a| name_language_helper(a.watched,current_user,0, :no_bold => true).downcase}
        @watched[k].sort_by! {|a| a.position || 100000 }      
        @watched[k] = v.map(&:watched)
      end  

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def watchlist_edit
    @user = User.includes({watchlists: :watched}).find(params[:id])
    
    @watched = @user.watchlists.group_by(&:grouping_category)    
    @watched.each do |k,v|
      @watched[k].sort_by! {|a| name_language_helper(a.watched,current_user,0, :no_bold => true).downcase}
      @watched[k].sort_by! {|a| a.position || 100000 }      
    end      
    @watched = @watched.sort_by { |k,v| (k ||= "").downcase}
    
    respond_to do |format|
      format.html # show.html.erb
    end    
  end
  
  def update_watchlist
    #Grab the new list of where each watched goes
    watchlist_edit = params[:watchlist_edit]
    #Remove the unsorted, as that will remain unsorted
    watchlist_edit.each do |grouping, values|
      unless grouping.nil? || grouping.empty?
        if values["records"].nil? == false
          values["records"].each_with_index do |id,n|
            watched = Watchlist.find_by_id(id)
            unless watched.nil?
              watched.grouping_category = values["name"]
              #Store position if position is there
              watched.position = (values["order"] == "1" ?  n : nil )
              watched.save
            end
          end          
        end
      end
    end    

    respond_to do |format|
      # if @user.save
        format.html { redirect_to watchlist_edit_user_path(:id => params[:id]), notice: 'Watchlist was successfully updated.' }
        # format.json { head :no_content }
      # else
        # format.html { render action: "edit_profile" }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
      # end
    end        
  end
  
  def collection
    @user = User.find(params[:id])
    @collection = @user.collections.includes(:album).order("albums.release_date").where(:relationship => "Collected")
    @ignorelist = @user.collections.includes(:album).order("albums.release_date").where(:relationship => "Ignored")
    @wishlist = @user.collections.includes(:album).order("albums.release_date").where(:relationship => "Wishlist")
  end
  
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
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
  end
  
  def update_security
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.update_security(params[:user])
        format.html { redirect_to user_path(:id => params[:id]), notice: 'Security was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit_security" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end    
  end

  def edit_profile
    @user = User.find(params[:id])
    #display settings
      displaysettings = @user.display_settings
      @displayhash = {}
      edit_profile_helper(displaysettings, @displayhash, "DisplayLEs", :les)
      edit_profile_helper(displaysettings, @displayhash, "DisplayNWS", :nws)
      edit_profile_helper(displaysettings, @displayhash, "DisplayIgnored", :ignored)
      edit_profile_helper(displaysettings, @displayhash, "AlbumArtOutline", :albumart)
      edit_profile_helper(displaysettings, @displayhash, "Bolding", :bold)
      edit_profile_helper(displaysettings, @displayhash, "EditMode", :editmode)
    #privacy settings
      privacyarray = User::PrivacySettings
      privacy = privacyarray.reject { |r| ((@user.privacy.to_i || 0 ) & 2**privacyarray.index(r)).zero?}
      @privacyhash = {}
      edit_profile_helper(privacy, @privacyhash, "ShowWatchlist", :watchlist)
      edit_profile_helper(privacy, @privacyhash, "ShowCollection", :collection)
    #Language Settings
      if @user.language_settings == nil
        @languages = User::Languages.split(",")
      else
        @languages = (@user.language_settings.split(",") + User::Languages.split(",")).uniq
      end
      if @user.artist_language_settings == nil
        @artistlanguages = User::Languages.split(",")
      else
        @artistlanguages = (@user.artist_language_settings.split(",") + User::Languages.split(",")).uniq
      end
  end

  def update_profile
    @user = User.find(params[:id])
    
    #Make sure they don't send in security or name changes.
    if params[:user].nil? == false
      params[:user].delete :security
      params[:user].delete :name
      params[:user].delete :email
    end
    #Update Display Settings
    displayarray = User::DisplaySettings
    @user.display_bitmask= (params[:displaysettings] & displayarray).map { |r| 2**displayarray.index(r) }.sum
    
    #Update Privacy Settings
    privacyarray = User::PrivacySettings
    @user.privacy = (params[:privacysettings] & privacyarray).map { |r| 2**privacyarray.index(r) }.sum
    
    #Update Language Settings
    @user.language_settings = params[:languagesettings].join(",")
    @user.artist_language_settings = params[:artistlanguagesettings] .join(",")
    
    #Tracklist Export options
    tracklistarray = Album::TracklistOptions.map {|k,v| k.to_s}
    @user.tracklist_export_bitmask = (params[:tracklist_export_settings] & tracklistarray).map { |r| 2**tracklistarray.index(r) }.sum
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to edit_profile_user_path(:id => params[:id]), notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit_profile" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    
    #Set Default Language Settings
    @user.language_settings = User::Languages
    @user.artist_language_settings = User::Languages
    @user.security = "2"
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to :root, notice: 'User was successfully created.' }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def passwordresetrequest
    user = User.find_by_email(params[:email])
    if user.nil? == false
      user.deliver_password_reset_instructions!
    end
    
    respond_to do |format|
      if user.nil? == false
        format.html { redirect_to requestpasswordreset_path, notice: 'Thank you! Please check your email for a link to reset your password.'  }
        format.json { head :no_content }
      else
        format.html { redirect_to requestpasswordreset_path, notice: 'The email entered was not registered to any account!' }
        format.json { head :no_content }
      end
    end 
  end
  
  def resetpassword
    @token = params[:token]
    @user = User.find_using_perishable_token(@token)
    
    unless @user
      flash[:error] = "Sorry, but we could not find the associated token"
      redirect_to :root
    end
  end
  
  def passwordreset
    user = User.find_using_perishable_token(params[:user][:token])
  
    unless user
      flash[:error] = "Sorry, but we could not find the associated token"
      redirect_to :root
    end    
    
    user.password = params[:user][:password]
    user.password_confirmation = params[:user][:password_confirmation]
    
    respond_to do |format|
      if user.save
        format.html { redirect_to :root }
        format.json { head :no_content }
      else
        format.html { redirect_to resetpassword_path, notice: 'Failed to reset password' }
        format.json { head :no_content }
      end
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
