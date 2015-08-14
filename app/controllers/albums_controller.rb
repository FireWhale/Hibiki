class AlbumsController < ApplicationController
  load_and_authorize_resource
  layout "full", only: [:edit, :new]
  
  def index
    @albums = Album.includes(:primary_images, :tags, :translations).order(:release_date).filter_by_user_settings(current_user).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @album = Album.includes({artist_albums: [artist: [:watchlists, :translations]]}, :primary_images, [sources: [:watchlists, :translations]], [album_organizations: [organization: [:watchlists, :translations]]], [songs: :translations], :tags).find(params[:id])
    self_relation_helper(@album,@related = {}) #Prepare @related (self_relations) 
    credits_helper(@album,@credits = {}) #prepares the credits

    #Organizations
    @organizations = {}
    @album.album_organizations.each do |each|
      (@organizations[each.category.pluralize] ||= []) << each.organization
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json do
        @fields = (params[:fields] || '').split(',')
        @fields << 'full_song_info' unless params[:full_song_info].blank?
      end
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
    @show_nws = params[:show_nws]
    
    respond_to do |format|
      format.html { render layout: "grid" }
      format.js { render template: "images/update_image"}
      format.json { render json: @album.images }
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
    @album = Album.includes({artist_albums: :artist}, {album_sources: :source}, {album_organizations: :organization}, :songs).find(params[:id])
    @album.namehash = @album.namehash || {}
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @album }
    end
  end

  def edit_tracklist
    @album = Album.includes({songs: [:tags, :translations, {song_sources: {source: :translations}},{artist_songs: {artist: :translations}}]}, {artists: [:translations, :watchlists]}, {sources: [:translations, :watchlists]}).find_by_id(params[:id])
  
    respond_to do |format|
      format.html { render layout: "full"}
      format.json { render json: @album }
    end
  end
    
  def create
    @album = Album.new(params[:album])
    
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
  
  def update_tracklist
    @album = Album.find_by_id(params[:id])
    Song.full_update(params["song"].keys, params["song"].values) unless params["song"].nil?
         
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
    @post = Post.where(category: "Rescrape Result").last
    if @post.content.length > 10000
      @post = Post.new(:content => "Rescrape tracker. Replaces Post ##{@post.id} on #{Date.today.to_s}\n",
                      :visibility => "Scraper", :category => "Rescrape Result", :status => "Released")
      @post.save
    end
    
    unless @album.references('VGMdb').nil?
      scrapehash = {}
      scrapehash[:rescrape_vgmdb] = [@album.id]
      
      ScrapeWorker.perform_async(scrapehash,@post.id)
      @album.taglists.where(:tag_id => 50).first.destroy unless @album.taglists.where(:tag_id => 50).blank?
    end 
    
    respond_to do |format|
      format.html { redirect_to @album, notice: "Rescraped" }
      format.json { head :no_content }
    end 
  end
  
end
