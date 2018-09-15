class SourcesController < ApplicationController
  load_and_authorize_resource
  include GenViewsModule

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
