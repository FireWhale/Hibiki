class SourcesController < ApplicationController
  load_and_authorize_resource

  autocomplete :source, :namehash, :full => true, :extra_data => [:name], 
               :display_value => :edit_format
      
  def index
    @sources = Source.order('lower(name)').includes([:watchlists, :tags, albums: :primary_images]).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sources }
    end
  end

  def show
    @source = Source.includes([:watchlists, :albums => [:primary_images, :tags]]).find(params[:id])
    self_relation_helper(@source,@related = {}) #Prepare @related (self_relations)
    
    @albums = @source.albums.filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @source }
      format.js
    end
  end

  def show_images
    @source = Source.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @source.primary_images.first
    elsif @source.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @source.images.first
    end  
    
    respond_to do |format|
      format.html
      format.json { render json: @source.images }
    end
  end

  def new
    @source = Source.new
    @source.namehash = @source.namehash || {}
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @source }
    end
  end

  def edit
    @source = Source.find(params[:id])
    @source.namehash = @source.namehash || {}
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @source }
    end
  end

  def create    
    @source = Source.new(params[:source])
    
    respond_to do |format|
      if @source.full_save(params[:source])
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render json: @source, status: :created, location: @source }
      else
        format.html { render action: "new" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @source = Source.find(params[:id])
    
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

  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to sources_url }
      format.json { head :no_content }
    end
  end
end
