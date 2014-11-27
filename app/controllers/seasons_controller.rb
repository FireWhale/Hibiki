class SeasonsController < ApplicationController
  load_and_authorize_resource

  def index
    @seasons = Season.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @seasons }
    end
  end

  def show
    @season = Season.includes({source_seasons: {source: {album_sources: {album: [:primary_images, {songs: :song_sources}]}}}}).find(params[:id])

    #First grab relations with albums that fall within our season's dates
    relations = @season.source_seasons.map(&:source).map(&:album_sources).flatten

    #@sources it not originally a list of sources. Rather, it is a list of source_seasons
    #It turns into sources within one line, though. 
      @sources = @season.source_seasons.group_by(&:category)
      @sources.each do |k,v|
        @sources[k] = v.map(&:source)
        @sources[k].sort_by! { |a| name_language_helper(a,current_user,0, :no_bold => true).downcase}
      end
      
      #We need to count how many relations are in each source.
      groupedrelations = relations.group_by(&:source_id)
      @sources.values.flatten.each do |source|
        if groupedrelations[source.id].nil? == false
          source.album_count = groupedrelations[source.id].count
        end
      end
      
    #Now we need to group our albums.     
    @albums = relations.map(&:album).sort_by(&:release_date).uniq
 
    #Get the current week.
    # @week = Date.today.beginning_of_week(start_day = :sunday)
       
    @albums.each do |album|
      #grab all the albumrelations that had this album. 
      albumrelations = relations.select { |relation| relation.album_id == album.id}
      #All albums for this week should be flagged yes. 
      # if album.week == @week
        # yn = 'y'
        #We need to add source's flag to set the div class to warning.
        # mappedids = albumrelations.map(&:source_id)
        # flaggedsources = @sources.values.flatten.select { |a| mappedids.include?(a.id)}
        # flaggedsources.each do |source|
          # source.flag = 'warning'
        # end
      # else
        yn = 'n'
      # end
      #we then add information to each album that we need to display them. 
      albumrelations.each do |each|
        if each.class == ArtistAlbum
          (album.flag ||= []) << 'a' + each.artist_id.to_s + yn
          (album.list_text ||= []) << name_language_helper(each.artist,current_user,0, :no_bold => true)
        elsif each.class == AlbumSource
          (album.flag ||= []) << 's' + each.source_id.to_s + yn
          #For sources, we can list OP/ED too
            #get a list of songsources of the album:
            songsources = album.songs.map(&:song_sources).flatten
            #find the ones that match the source in question
            songsources = songsources.select { |relation| relation.source_id == each.source_id}
            if songsources.nil? || songsources.empty?
              (album.list_text ||= []) << name_language_helper(each.source,current_user,0, :no_bold => true)
            else
              oped = songsources.map(&:classification).reject {|c| c.nil? || c.empty?}
              if oped.nil? || oped.empty?
                (album.list_text ||= []) << name_language_helper(each.source,current_user,0, :no_bold => true)
              else
                (album.list_text ||= []) << (name_language_helper(each.source,current_user,0, :no_bold => true) + ' (' + oped.join(' & ') + ')')
              end              
            end
        elsif each.class == AlbumOrganization
          (album.flag ||= []) << 'o' + each.organization_id.to_s + yn
          (album.list_text ||= []) << name_language_helper(each.organization,current_user,0, :no_bold => true)
        end
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @season }
    end
  end

  def new
    @season = Season.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @season }
    end
  end

  def edit
    @season = Season.find(params[:id])
    @sourceseasons = @season.source_seasons
  end

  def create
    respond_to do |format|
      if @season.full_save(params[:season])
        format.html { redirect_to @season, notice: 'Season was successfully created.' }
        format.json { render json: @season, status: :created, location: @season }
      else
        format.html { render action: "new" }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @season = Season.find(params[:id])
    
    #Create new source_season records.
    sourceids = params[:sourceids]
    sourcecategories = params[:sourcecategories]
    if sourceids.nil? == false
      sources = sourceids.zip(sourcecategories)
      
      sources.each do |each|
        if each[0].empty? == false
          source = Source.find(each[0])
          @season.source_seasons.create(:source_id => source.id, :category => each[1] )
        end
      end
    end
    
    #Update existing source_season records
    source_seasons = params[:source_seasons]
    if source_seasons.nil? == false
      source_seasons.each do |k,v|
        SourceSeason.update(k,v)
      end
    end
      
    respond_to do |format|
      if @season.update_attributes(params[:season])
        format.html { redirect_to @season, notice: 'Season was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @season = Season.find(params[:id])
    @season.destroy

    respond_to do |format|
      format.html { redirect_to seasons_url }
      format.json { head :no_content }
    end
  end
end
