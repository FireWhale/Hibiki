class ArtistsController < ApplicationController
  load_and_authorize_resource
  
  autocomplete :artist, :namehash, :full => true, :extra_data => [:name], :display_value => :format_method  

  def index
    @artists = Artist.order(:name).includes({artist_albums: {album: [:primary_images, :collections]}}).page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @artists }
    end
  end
  
  def show
    @artist = Artist.includes(:images).find(params[:id])
    self_relation_helper(@artist,@related = {}, otherids = []) #Prepare @related (self_relations)
    
    @collection = ArtistAlbum.includes(:artist, {album: [:related_album_relations1, :tags]}).where(:artist_id => @artist.id).order("albums.release_date")
    collectionids = @collection.map(&:album_id)
    
    otheridcollection = ArtistAlbum.includes(:album).where(:artist_id => otherids).order("albums.release_date")
 
    otheridcollection.each  {|relation| @collection << relation unless collectionids.include?(relation.album_id) }
    
    @collection.sort! { |a,b| a.album.release_date <=> b.album.release_date }
    #Take out reprints and alternate printings
    @collection = filter_albums(@collection)
        
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @artist }
    end
  end

  def show_images
    @artist = Artist.includes(:images).find_by_id(params[:id])
    if @artist.images.empty?
      #What if there are no album images? Shouldn't be able to get here, but...
    else
      if params[:image] == "cover"
        @image = @artist.primary_images.first
      else
        @image = @artist.images.first
      end      
    end
  end

  def addartistforsongform
    @songid = params[:song_id]
    #@defaultcat is not normally used in normal artist adding, but for scripted adding we need it.
    #^wow thanks past me, that's very useful
    @defaultcat = ''
    #check to see if this is a script function
    if params[:script].nil? == false
      @songids = params[:script][:div_ids].split(',')
      @defaultvalue = params[:script][:name]
      @defaultcat = params[:script][:artist_cat]
    end
  end
  
  def new
    @artist = Artist.new
    @artist.namehash = @artist.namehash || {}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @artist }
    end
  end

  # GET /artists/1/edit
  def edit
    @artist = Artist.find(params[:id])
    @artist.namehash = @artist.namehash || {}
  end

  # POST /artists
  # POST /artists.json
  def create
    respond_to do |format|
      if @artist.full_save(params[:artist])
        format.html { redirect_to @artist, notice: 'Artist was successfully created.' }
        format.json { render json: @artist, status: :created, location: @artist }
      else
        format.html { render action: "new" }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /artists/1
  # PUT /artists/1.json
  def update
    @artist = Artist.find(params[:id])
       
    respond_to do |format|
      if @artist.full_update_attributes(params[:artist])
        format.html { redirect_to @artist, notice: 'Artist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @artist = Artist.find(params[:id])
    @artist.destroy

    respond_to do |format|
      format.html { redirect_to artists_url }
      format.json { head :no_content }
    end
  end
end