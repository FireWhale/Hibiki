class ArtistsController < ApplicationController
  load_and_authorize_resource
  include GenViewsModule
  include ImageViewModule

  def create
    @form = ArtistForm.new(artist_params)

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice: 'Artist was successfully created.' }
        format.json { render json: @form.record, status: :created, location: @form.record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @form = ArtistForm.new(artist_params.merge(record: Artist.find(params[:id])))
       
    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice: 'Artist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
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
  
  class ArtistParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:artist_form).permit!
      elsif current_user
        params.require(:artist_form).permit()
      else
        params.require(:artist_form).permit()
      end         
    end
  end
  
  
  private
    def artist_params
      ArtistParams.filter(params,current_user)
    end
end