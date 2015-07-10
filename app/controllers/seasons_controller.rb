class SeasonsController < ApplicationController
  load_and_authorize_resource

  def index
    @seasons = Season.order(:start_date)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @seasons }
    end
  end

  def show
    @season = Season.includes(source_seasons: [source: :translations]).find(params[:id])

    @sources = @season.source_seasons.group_by(&:category)
    @sources.each do |k,v|
      @sources[k] = v.map(&:source)
      @sources[k].sort_by! { |a| language_helper(a, :name, highlight: false).downcase}
    end
      
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @season }
    end
  end

 def show_images
    @season = Season.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @season.primary_images.first
    elsif @season.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @season.images.first
    end
    @show_nws = params[:show_nws]

    respond_to do |format|
      format.html 
      format.js { render template: "images/update_image"}
      format.json { render json: @season.images }
    end
  end

  def new
    @season = Season.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @season }
    end
  end

  def edit
    @season = Season.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @season }
    end
  end

  def create
    respond_to do |format|
      if @season.full_save(params[:season])
        format.html { redirect_to @season, notice: 'Season was successfully created.' }
        format.json { render json: @season, status: :created, location: @season }
      else
        format.html { render action: "new" }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @season = Season.find(params[:id])
    
    respond_to do |format|
      if @season.full_update_attributes(params[:season])
        format.html { redirect_to @season, notice: 'Season was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @season = Season.find(params[:id])
    @season.destroy

    respond_to do |format|
      format.html { redirect_to seasons_url }
      format.json { head :no_content }
    end
  end
end
