class ImagesController < ApplicationController  
  load_and_authorize_resource


  include ImagesModule 

  def updateimage
    #This is used for showalbumart and other 'show images for primary models' pages
    @image = Image.find(params[:id])
    @show_nws = params[:show_nws]
  end

  def index
    @images = Image.page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(params[:image])

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render json: @image, status: :created, location: @image }
      else
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.full_update_attributes(params[:image])
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    if @image.imagelists.empty? == false
      #This code redirects to the record the image belonged to.
      @record = @image.imagelists.first.model_type.constantize.find(@image.imagelists.first.model_id)
    end
    @image.destroy

    respond_to do |format|
      if @record.nil? == false
        format.html { redirect_to @record }
      else
        format.html { redirect_to :root }
      end
      format.json { head :no_content }
    end
  end
end
