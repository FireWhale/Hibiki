class SourcesController < ApplicationController
  load_and_authorize_resource

  autocomplete :source, :namehash, :full => true, :extra_data => [:name, :search_context], 
               :display_value => :autocomplete_format
  
  
  def addsourceforsongform
    #For normal source adding to a single song
    @songid = params[:song_id]
    #For scripted mass adding to all songs
    if params[:script].nil? == false
      @songids = params[:script][:div_ids].split(',')
      @defaultvalue = params[:script][:name]
    end    
  end
      
  def index
    @sources = Source.order('lower(name)').includes(albums: :primary_images).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sources }
    end
  end

  def show
    @source = Source.includes(:albums, :organizations, :images).find(params[:id])
    self_relation_helper(@source,@related = {}) #Prepare @related (self_relations)

    @collection = AlbumSource.includes(album: [:related_album_relations1]).where(source_id: @source.id).order("albums.release_date")
    
    #Take out reprints and alternate printings
    @collection = filter_albums(@collection)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @source }
    end
  end

  def showimages
    @source = Source.includes(:images).find_by_id(params[:id])
    if @source.images.empty?
      #What if there are no album images? Shouldn't be able to get here, but...
    else
      if params[:image] == "cover"
        @image = @source.primary_images.first
      else
        @image = @source.images.first
      end      
    end
  end

  # GET /sources/new
  # GET /sources/new.json
  def new
    @source = Source.new
    @source.namehash = @source.namehash || {}
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = Source.find(params[:id])
    @source.namehash = @source.namehash || {}
    
  end

  # POST /sources
  # POST /sources.json
  def create
    params[:source] = params[:source].deep_symbolize_keys
    
    #Namehash
    params[:source][:namehash].delete_if { |key,value| value.empty?}
    
    respond_to do |format|
      if @source.full_create(params[:source])
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render json: @source, status: :created, location: @source }
      else
        format.html { render action: "new" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.json
  def update
    @source = Source.find(params[:id])
    params[:source] = params[:source].deep_symbolize_keys

    #Namehash
    params[:source][:namehash].delete_if { |key,value| value.empty?}
    
    respond_to do |format|
      if @source.full_update_attributes(params[:source])
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to sources_url }
      format.json { head :no_content }
    end
  end
end
