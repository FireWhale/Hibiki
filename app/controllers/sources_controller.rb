class SourcesController < ApplicationController
  load_and_authorize_resource
  layout "full", only: [:edit, :new]
      
  def index
    @sources = Source.order(:internal_name).includes([:translations, :watchlists, :tags]).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @source = Source.includes([:watchlists, :translations, :albums => [:primary_images, :translations, :tags]]).find(params[:id])
    self_relation_helper(@source,@related = {}) #Prepare @related (self_relations)
    
    @albums = @source.albums.filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])
    
    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.json {@fields = (params[:fields] || '').split(',')}
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
    @show_nws = params[:show_nws]
    
    respond_to do |format|
      format.html {render layout: "grid" }
      format.js { render template: "images/update_image"}
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
    new_params = source_params
    handle_partial_date_assignment(new_params,Source)
    
    @source = Source.new(new_params)
    
    respond_to do |format|
      if @source.save
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render json: @source, status: :created, location: @source }
      else
        format.html { render action: "new" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_params = source_params
    handle_partial_date_assignment(new_params,Source)
    
    @source = Source.find(params[:id])
    
    respond_to do |format|
      if @source.update_attributes(new_params)
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
  
  class SourceParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:source).permit( "internal_name", "status", "synonyms", "db_status", "release_date", "end_date", "plot_summary", "info", "private_info", "synopsis", "activity", "category", 
                                        "new_images" => [], "remove_source_organizations" => [], "remove_related_sources" => [], "namehash" => params[:source][:namehash].try(:keys),
                                        "new_references" => [:site_name => [], :url => []], "update_references" => [:site_name, :url], 
                                         :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:source][:name_langs].try(:keys),
                                         :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:source][:info_langs].try(:keys),
                                         :new_related_sources => [:id => [], :category =>[]], :update_related_sources => :category,
                                         :new_organizations => [:id => [], :category => []], :update_source_organizations => [:category]
                                        )
      elsif current_user
        params.require(:source).permit()
      else
        params.require(:source).permit()
      end         
    end
  end
  
  
  private
    def source_params
      SourceParams.filter(params,current_user)
    end
end
