class ArtistsController < ApplicationController
  load_and_authorize_resource
  
  autocomplete :artist, :namehash, :full => true, :extra_data => [:name], 
               :display_value => :edit_format  
               
  def index
    @artists = Artist.order(:name).includes([:watchlists, :tags, albums: :primary_images]).page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @artists }
    end
  end
  
  def show
    @artist = Artist.includes(:primary_images, :organizations => [:watchlists]).find(params[:id])
    self_relation_helper(@artist,@related = {}) #Prepare @related (self_relations)
        
    @albums = @artist.albums.includes(:primary_images, :tags).filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])
    
    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.json { render json: @artist }
    end
  end

  def show_images
    @artist = Artist.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @artist.primary_images.first
    elsif @artist.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @artist.images.first
    end

    respond_to do |format|
      format.html 
      format.json { render json: @artist.images }
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

  def edit
    @artist = Artist.find(params[:id])
    @artist.namehash = @artist.namehash || {}
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @artist }
    end
  end

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