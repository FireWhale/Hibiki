class OrganizationsController < ApplicationController
  load_and_authorize_resource
  
  autocomplete :organization, :namehash, :full => true, :extra_data => [:name], 
               :display_value => :edit_format

  def index
    @organizations = Organization.order(:name).includes({album_organizations: {album: :primary_images}}).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organizations }
    end
  end

  def show
    @organization = Organization.includes(:artists, :sources, :images, :albums => [:primary_images, :tags]).find(params[:id])
    self_relation_helper(@organization,@related = {}) #Prepare @related (self_relations)

    @albums = @organization.albums.includes(:primary_images, :tags).filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])

    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.json { render json: @organization }
    end
  end
  
  def show_images
    @organization = Organization.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @organization.primary_images.first
    elsif @organization.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @organization.images.first
    end  
    
    respond_to do |format|
      format.html 
      format.json { render json: @organization.images }
    end
  end

  def new
    @organization = Organization.new
    @organization.namehash = @organization.namehash || {}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization }
    end
  end

  def edit
    @organization = Organization.find(params[:id])
    @organization.namehash = @organization.namehash || {}
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @organization }
    end
  end

  def create
    respond_to do |format|
      if @organization.full_save(params[:organization])
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render json: @organization, status: :created, location: @organization }
      else
        format.html { render action: "new" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @organization = Organization.find(params[:id])
    
    respond_to do |format|
      if @organization.full_update_attributes(params[:organization])
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :no_content }
    end
  end
end
