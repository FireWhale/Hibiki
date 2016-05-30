class SongsController < ApplicationController
  load_and_authorize_resource
  layout "full", only: [:edit, :new]

  def index
    @songs = Song.includes(:tags, :translations, album: [:primary_images, :translations]).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json 
    end
  end

  def show
    @song = Song.includes(:translations).find(params[:id])
    
    self_relation_helper(@song,@related = {}) #Prepare @related (self_relations) 
    credits_helper(@song,@credits = {}) #prepares the credits
        
    respond_to do |format|
      format.html { redirect_to album_path(id: @song.album.id, :anchor => "song-#{@song.id}") unless @song.album.nil? }
      format.json  {@fields = (params[:fields] || '').split(',')}
    end
  end

  def show_images
    @song = Song.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @song.primary_images.first
    elsif @song.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @song.images.first
    end
    @show_nws = params[:show_nws]

    respond_to do |format|
      format.html { render layout: "grid"}
      format.js { render template: "images/update_image"}
      format.json { render json: @song.images }
    end
  end

  def new
    @song = Song.new
    @song.namehash = @song.namehash || {}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @song }
    end
  end

  def edit
    @song = Song.find(params[:id])
    @song.namehash = @song.namehash || {}
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @song }
    end
  end

  def create
    new_params = song_params
    handle_length_assignment(new_params)
    handle_partial_date_assignment(new_params,Song)
    
    @song = Song.new(new_params)
    
    respond_to do |format|
      if @song.save
        format.html { redirect_to @song, notice: 'Song was successfully created.' }
        format.json { render json: @song, status: :created, location: @song }
      else
        format.html { render action: "new" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_params = song_params
    handle_length_assignment(new_params)
    handle_partial_date_assignment(new_params,Song)

    @song = Song.find(params[:id])
    
    respond_to do |format|
      if @song.update_attributes(new_params)
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end
  
  class SongParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:song).permit("internal_name","track_number","length","release_date","synonyms","info","private_info",
                                     "disc_number", "status", "new_images" => [], "remove_song_sources" => [], "remove_related_songs" => [], "namehash" => params[:song][:namehash].try(:keys),
                                     "new_references" => [:site_name => [], :url => []], "update_references" => [:site_name, :url], 
                                     :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:song][:name_langs].try(:keys),
                                     :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:song][:info_langs].try(:keys),
                                     :new_lyrics_langs => [], :new_lyrics_lang_categories => [], :lyrics_langs => params[:song][:lyrics_langs].try(:keys), 
                                     :new_related_songs => [:id => [], :category =>[]], :update_related_songs => :category,
                                     :new_artists => [:id => [], :category => []], :update_artist_songs => {:category => []},
                                     :new_sources => [:id => [], :classification => [], :op_ed_number => [], :ep_numbers => []], :update_song_sources => [:classification, :op_ed_number, :ep_numbers]
                                       )
      elsif current_user
        params.require(:song).permit()
      else
        params.require(:song).permit()
      end             
    end
  end
  
  private
    def song_params
      SongParams.filter(params,current_user)
    end
end
