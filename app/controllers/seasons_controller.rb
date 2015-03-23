class SeasonsController < ApplicationController
  load_and_authorize_resource

  def index
    @seasons = Season.order(:start_date).group_by { |e| e.start_date.year }

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
    
    respond_to do |format|
      if @season.full_update_attributes(params[:season])
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
