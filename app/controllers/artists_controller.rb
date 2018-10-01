class ArtistsController < ApplicationController
  load_and_authorize_resource
  include GenViewsModule

  def create
    new_params = artist_params
    handle_partial_date_assignment(new_params,Artist)

    @record = Artist.new(new_params)
    
    respond_to do |format|
      if @record.save
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Artist was successfully created.' }
        format.json { render json: @record, status: :created, location: @record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_params = artist_params
    handle_partial_date_assignment(new_params,Artist)

    @record = Artist.find(params[:id])
       
    respond_to do |format|
      if @record.update_attributes(new_params)
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Artist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
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
        params.require(:artist).permit("internal_name", "status", "synopsis", "category", "db_status", "info", "private_info", "synonyms", "activity", "birth_place", "gender", "birth_date", "debut_date", "blood_type",
                                        "new_images" => [], "remove_artist_organizations" => [], "remove_related_artists" => [], "namehash" => params[:artist][:namehash].try(:keys),
                                        "new_references" => [:site_name => [], :url => []], "update_references" => [:site_name, :url], 
                                         :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:artist][:name_langs].try(:keys),
                                         :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:artist][:info_langs].try(:keys),
                                         :new_related_artists=> [:id => [], :category =>[]], :update_related_artists => :category,
                                         :new_organizations => [:id => [], :category => []], :update_artist_organizations => [:category]        
        )
      elsif current_user
        params.require(:artist).permit()
      else
        params.require(:artist).permit()
      end         
    end
  end
  
  
  private
    def artist_params
      ArtistParams.filter(params,current_user)
    end
end