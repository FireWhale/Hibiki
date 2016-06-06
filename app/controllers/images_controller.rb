class ImagesController < ApplicationController
  load_and_authorize_resource

  def index
    @images = Image.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json {@fields = (params[:fields] || '').split(',')}
    end
  end

  def edit
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @image }
    end
  end

  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

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

  class ImageParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:image).permit(:name, :rating,:primary_flag)
      elsif current_user
        params.require(:image).permit()
      else
        params.require(:image).permit()
      end
    end
  end

  private
    def image_params
      ImageParams.filter(params,current_user)
    end
end
