class AlbumsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  include ImageViewModule

  def index
    @records = PrimaryRecordGetter.perform('index',model: 'album', page: params[:page]).filter_by_user_settings(current_user)

    respond_to do |format|
      format.html {render file: 'shared/index' }
      format.json {render file: 'shared/index'}
    end
  end

  def show
    @record = Album.includes({artist_albums: [artist: [:watchlists, :translations]]}, :primary_images, [sources: [:watchlists, :translations]], [album_organizations: [organization: [:watchlists, :translations]]], [songs: :translations], :tags).find(params[:id])
    self_relation_helper(@record,@related = {}) #Prepare @related (self_relations)
    credits_helper(@record,@credits = {}) #prepares the credits

    #Organizations
    @organizations = {}
    @record.album_organizations.each do |each|
      (@organizations[each.category.pluralize] ||= []) << each.organization
    end

    respond_to do |format|
      format.html {render file: 'shared/show' }
      format.json do
        @fields = (params[:fields] || '').split(',')
        @fields << 'full_song_info' unless params[:full_song_info].blank?
        render file: 'shared/show'
      end
    end
  end

  def new
    @form = AlbumForm.new

    respond_to do |format|
      format.html  { render file: 'shared/new', layout: 'full'}
      format.json { render json: @form }
    end
  end

  def edit
    @record = Album.includes({artist_albums: :artist}, {album_sources: :source}, {album_organizations: :organization}, :songs).find(params[:id])
    @form = AlbumForm.new(record: @record)

    respond_to do |format|
      format.html { render file: 'shared/edit', layout: 'full'}
      format.json { render json: @form }
    end
  end

  def edit_tracklist
    @album = Album.includes({songs: [:tags, :translations, {song_sources: {source: :translations}},{artist_songs: {artist: :translations}}]}, {artists: [:translations, :watchlists]}, {sources: [:translations, :watchlists]}).find_by_id(params[:id])
    @songs = @album.songs

    respond_to do |format|
      format.html { render layout: "full"}
      format.json { render json: @album }
    end
  end

  def create
    @form = AlbumForm.new(album_params)

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice: "#{@form.record.class} was successfully created." }
        format.json { render json: @form.record, status: :created, location: @form.record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @form = AlbumForm.new(album_params.merge(record: Album.find(params[:id])))

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice:  "#{@form.record.class} was successfully updated." }
        format.json { head :no_content }
      else
        @record = @form.record.class.find(params[:id])
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_tracklist
    @album = Album.find_by_id(params[:id])
    songs = @album.songs
    song_params = tracklist_params

    handle_length_assignment(song_params)

    @songs = []
    unless song_params[:song].blank?
      song_params[:song].each do |id,values|
        song = songs.find_by_id(id) #Doing it this way instead of @album.songs.find(id) to preseve reference and thus errors.
        song.update_attributes(values) unless song.nil?
        @songs << song unless song.nil?
      end
    end

    respond_to do |format|
      if @songs.all? { |song| song.valid? }
        format.html { redirect_to @album, notice: 'Tracklist updated!' }
        format.json { head :no_content }
      else
        format.html { render action: "edit_tracklist", layout: "full" }
        format.json { render json @songs.map { |song| {song.id => song.errors}}}
      end
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

    unless @album.references('VGMdb').nil?
      ScrapeWorker.perform_async({:rescrape => {:vgmdb_albums => [@album.id]}})
      @album.taglists.where(:tag_id => 50).first.destroy unless @album.taglists.where(:tag_id => 50).blank?
    end

    respond_to do |format|
      unless @album.references('VGMdb').nil?
        format.html { redirect_to @album, notice: "Rescraped" }
        format.json { head :no_content }
      else
        format.html { redirect_to @album, notice: "Failed! No VGMdb Reference Listed!" }
        format.json { head :no_content }
      end
    end
  end

  class AlbumParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:album_form).permit!
      elsif current_user
        params.require(:album_form).permit()
      else
        params.require(:album_form).permit()
      end
    end

    def self.tracklist_filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:tracklist_form).permit!
      elsif current_user
        params.require(:tracklist_form).permit()
      else
        params.require(:tracklist_form).permit()
      end
    end

  end

  private
    def album_params
      AlbumParams.filter(params,current_user)
    end

    def tracklist_params
      AlbumParams.tracklist_filter(params,current_user)
    end

end
