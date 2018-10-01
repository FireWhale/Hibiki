class SongsController < ApplicationController
  load_and_authorize_resource
  layout "full", only: [:edit, :new]

  def index
    @records = PrimaryRecordGetter.perform('index',model: 'song', page: params[:page])

    respond_to do |format|
      format.html {render file: 'shared/index' }
      format.json {render file: 'shared/index'}
    end
  end

  def show
    @record = Song.includes(:translations).find(params[:id])
    
    self_relation_helper(@record,@related = {}) #Prepare @related (self_relations)
    credits_helper(@record,@credits = {}) #prepares the credits
        
    respond_to do |format|
      format.html do
        if @record.album.nil?
          render file: 'shared/show'
        else
          redirect_to album_path(id: @record.album.id, :anchor => "song-#{@record.id}")
        end
      end
      format.json do
        @fields = (params[:fields] || '').split(',')
        @fields << 'full_song_info' unless params[:full_song_info].blank?
        render file: 'shared/show'
      end
    end
  end

  def show_images
    @record = Song.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @record.primary_images.first
    elsif @record.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @record.images.first
    end
    @show_nws = params[:show_nws]

    respond_to do |format|
      format.html {render file: 'shared/show_images', layout: 'grid'}
      format.js { render template: "images/update_image"}
      format.json { render json: @record.images }
    end
  end

  def new
    @record = Song.new
    @record.namehash ||= {}

    respond_to do |format|
      format.html  { render file: 'shared/new', layout: 'full'}
      format.json { render json: @record }
    end
  end

  def edit
    @record = Song.find(params[:id])
    @record.namehash ||= {}
    
    respond_to do |format|
      format.html { render file: 'shared/edit', layout: 'full'}
      format.json { render json: @record }
    end
  end

  def create
    new_params = song_params
    handle_length_assignment(new_params)
    handle_partial_date_assignment(new_params,Song)

    @record = Song.new(new_params)
    
    respond_to do |format|
      if @record.save
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Song was successfully created.' }
        format.json { render json: @record, status: :created, location: @record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_params = song_params
    handle_length_assignment(new_params)
    handle_partial_date_assignment(new_params,Song)

    @record = Song.find(params[:id])
    
    respond_to do |format|
      if @record.update_attributes(new_params)
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
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
