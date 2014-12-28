class AlbumsController < ApplicationController
  load_and_authorize_resource
  
  autocomplete :album, :namehash, :full => true, :extra_data => [:name], :display_value => :format_method  
    
  def index
    @albums = Album.includes(:primary_images).order(:release_date).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  def show
    @album = Album.includes({artist_albums: :artist}, :primary_images, :sources, {album_organizations: :organization}, :songs, :tags).find(params[:id])
    self_relation_helper(@album,@related = {}) #Prepare @related (self_relations) 
    credits_helper(@album,@credits = {}) #prepares the credits

    #Organizations
    @organizations = {}
    @album.album_organizations.each do |each|
      (@organizations[each.category.pluralize] ||= []) << each.organization
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album }
    end
  end
   
  def album_art
    @album = Album.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @album.primary_images.first
    elsif @album.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @album.images.first
    end  
  end
  
  def album_preview
    @album = Album.includes(:images).find_by_id(params[:id])
    
    respond_to do |format|
      format.html { redirect_to @album}
      format.js
    end    
  end
      
  def tracklist_export
    @album = Album.includes(songs: {artist_songs: :artist}).find(params[:id])
    #Send params to view to know if box should be checked
    @params = params      

    #User defaults
    if current_user.nil? 
      @user_defaults = Album::TracklistOptions.map {|k,v| k.to_s }
    else
      @user_defaults = current_user.tracklist_settings
    end
    #set up row and tracklist variables:
      @foobarscheme = ""    
      @foobartracklist = ""
      @rows = 1  
    #Set the scheme
      #Disc and track number
          if (params[:disc_number].nil? == false && params[:track_number].nil? == false) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') && @user_defaults.include?('track_number'))
            @foobarscheme = @foobarscheme + "%discnumber%.%tracknumber%"
          elsif (params[:disc_number].nil? == false && params[:track_number].nil?) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') && @user_defaults.include?('track_number') == false)
            @foobarscheme = @foobarscheme + "%discnumber%"
          elsif (params[:disc_number].nil? && params[:track_number].nil? == false) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') == false && @user_defaults.include?('track_number') )
            @foobarscheme = @foobarscheme + "%tracknumber%"
          end
          if params[:title].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('title'))
            @foobarscheme = @foobarscheme + "|%title%"
          end
          if params[:performers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('performers'))
            @foobarscheme = @foobarscheme + "|%artist%"            
          end
          if params[:composers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('composers'))
            @foobarscheme = @foobarscheme + "|%composer%"            
          end
          if params[:performers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('performers'))
            @foobarscheme = @foobarscheme + "|%performer%"            
          end
          if params[:album].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('album'))
            @foobarscheme = @foobarscheme + "|%album%"      
          end
          if params[:sources].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('sources'))
            @foobarscheme = @foobarscheme + "|%source material%"      
          end
          if params[:year].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('year'))
            @foobarscheme = @foobarscheme + "|%date%"
          elsif params[:full_date].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('full_date'))
            @foobarscheme = @foobarscheme + "|%date%"
          end
          if params[:op].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('op'))
            @foobarscheme = @foobarscheme + "|%OP/ED/Insert%"
          end
          if params[:genres].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('genres'))
            @foobarscheme = @foobarscheme + "|%genre%"
          end
          if params[:catalog_number].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('catalog_number'))
            @foobarscheme = @foobarscheme + "|%catalog number%"            
          end
          if params[:events].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('events'))
            @foobarscheme = @foobarscheme + "|%event%"            
          end
          if params[:arrangers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('arrangers'))
            @foobarscheme = @foobarscheme + "|%arranger%"            
          end
    #Loop over songs
    @album.songs.each do |song|
      #Add a row to the row variable
      @rows = @rows + 1
      #Clear some variables
      performers = []
      composers = []
      arrangers = []
      #Find performers and composers just in case user wants to include compoers and performers.
      song.artist_songs.each do |each|
        categories = Artist.get_categories(each.category)
        if categories.include?("Performer") || categories.include?("FeatPerformer")
          performers << each.artist
        end
        if categories.include?("Composer") || categories.include?("FeatComposer")
          composers << each.artist
        end
        if categories.include?("Arranger") 
          arrangers << each.artist
        end
      end
      #For each song, we'll need to see what data we should put in. 
        #Disc and Tracknumber
          if (params[:disc_number].nil? == false && params[:track_number].nil? == false) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') && @user_defaults.include?('track_number'))
            @foobartracklist = @foobartracklist + song.tracknumber
          elsif (params[:disc_number].nil? == false && params[:track_number].nil?) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') && @user_defaults.include?('track_number') == false)
            @foobartracklist = @foobartracklist + song.tracknumber.split(".")[0]
          elsif (params[:disc_number].nil? && params[:track_number].nil? == false) || (params[:resubmit].nil? && @user_defaults.include?('disc_number') == false && @user_defaults.include?('track_number'))
            @foobartracklist = @foobartracklist + song.tracknumber.split(".")[1]
          end
        #Titles
          if params[:title].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('title'))
            @foobartracklist = @foobartracklist + "|" + name_language_helper(song,current_user,0, :no_bold => true)
          end
        #Performers as Artists
          if params[:performers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('performers'))
            @foobartracklist = @foobartracklist + "|"
            if performers.nil? == false
              @foobartracklist = @foobartracklist + performers.map { 
              |artist| name_language_helper(artist,current_user,0, :no_bold => true) }.join(";")
            end
          end
        #Composers
          if params[:composers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('composers'))
            @foobartracklist = @foobartracklist + "|"
            if composers.nil? == false
              @foobartracklist = @foobartracklist + composers.map { 
              |artist| name_language_helper(artist,current_user,0, :no_bold => true) }.join(";")
            end
          end
        #Performers as Performers
          if params[:performers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('performers'))
            @foobartracklist = @foobartracklist + "|"
            if @performers.nil? == false
              @foobartracklist = @foobartracklist + @performers.map { 
              |artist| name_language_helper(artist,current_user,0, :no_bold => true) }.join(";")
            end
          end
        #Albums
          if params[:album].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('album'))
              @foobartracklist = @foobartracklist + "|" + name_language_helper(song.album,current_user,0, :no_bold => true)
          end       
        #Source Material  
          if params[:sources].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('sources'))
            @foobartracklist = @foobartracklist + "|" + song.sources.map { 
            |source| name_language_helper(source,current_user,0, :no_bold => true) }.join(";")
          end
        #Dates
          if params[:year].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('year'))
            @foobartracklist = @foobartracklist + "|" + song.album.releasedate.to_s[0..3]
          elsif params[:full_date].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('full_date'))
            @foobartracklist = @foobartracklist + "|" + song.album.releasedate.to_s
          end        
        #OP/ED/Insert
          if params[:op].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('op'))
            @foobartracklist = @foobartracklist + "|" + song.op_ed_insert?.split(', ').join(';')
          end
        #Genres
          if params[:genres].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('genres'))
            @foobartracklist = @foobartracklist + "|" + song.tags.map {|tag| tag.name if tag.classification == "Genre" }.join(';')          
          end          
        #Catalog Number
          if params[:catalog_number].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('catalog_number'))
            @foobartracklist = @foobartracklist + "|" + song.album.catalognumber      
          end
        #Event 
          if params[:events].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('events'))
            @foobartracklist = @foobartracklist + "|" + song.album.events.map { |event| event.shorthand }.join(";")
          end
          if params[:arrangers].nil? == false || (params[:resubmit].nil? && @user_defaults.include?('arrangers'))
            @foobartracklist = @foobartracklist + "|"
            if arrangers.nil? == false
              @foobartracklist = @foobartracklist + arrangers.map { 
              |artist| name_language_helper(artist,current_user,0, :no_bold => true) }.join(";")
            end
          end

      #New Song
        @foobartracklist = @foobartracklist + "\n"
    end
   
  end
  
  def new
    @album = Album.new
    @album.namehash = @album.namehash || {}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end

  def edit
    @album = Album.includes({artist_albums: :artist}, :sources, {album_organizations: :organization}, :songs).find(params[:id])
    @album.namehash = @album.namehash || {}
  end
    
  def create
    respond_to do |format|
      if @album.full_save(params[:album])
        format.html { redirect_to @album, notice: 'Album was successfully created.' }
        format.json { render json: @album, status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @album = Album.includes({artist_albums: :artist}, :sources, {album_organizations: :organization}, :songs).find(params[:id])
        
    respond_to do |format|
      if @album.full_update_attributes(params[:album])
        format.html { redirect_to @album, notice: 'Album was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit_tracklist
    @album = Album.includes(songs: {artist_songs: :artist}).find_by_id(params[:id])
  end
    
  def update_tracklist
    @album = Album.find_by_id(params[:id])
    Song.full_update(params["song"].keys, params["song"].values)
         
    respond_to do |format|
        format.html { redirect_to @album, notice: 'Tracklist updated!' }
        format.json { head :no_content }
    end    
  end
  
  def destroy
    @album = Album.find(params[:id])
    @album.destroy

    respond_to do |format|
      format.html { redirect_to albums_url }
      format.json { head :no_content }
    end
  end
  
  def rescrape
    @album = Album.find(params[:id])
    
    if @album.reference[:VGMdb].nil? == false
      scrapehash = {}
      scrapehash[:vgmdb_albums] = []
      scrapehash[:vgmdb_artists] = []
      scrapehash[:vgmdb_organizations] = []
      scrapehash[:cdjapan_albums] = []
      scrapehash[:manifo_albums] = []
      scrapehash[:manifo_albums] = []
      scrapehash[:rescrape_vgmdb] = [@album.id]
      
      ScrapeWorker.perform_async(scrapehash,562)  
    end 
    
    respond_to do |format|
      format.html { redirect_to @album, notice: "Rescraped" }
      format.json { head :no_content }
    end 
  end
  
end
