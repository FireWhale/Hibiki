class OrganizationsController < ApplicationController
  load_and_authorize_resource
  include GenViewsModule

  def create
    new_params = organization_params
    handle_partial_date_assignment(new_params,Organization)

    @record = Organization.new(new_params)
    
    respond_to do |format|
      if @record.save
        format.html { redirect_to @record, notice: 'Organization was successfully created.' }
        format.json { render json: @record, status: :created, location: @record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_params = organization_params
    handle_partial_date_assignment(new_params,Organization)
        
    @record = Organization.find(params[:id])
    
    respond_to do |format|
      if @record.update_attributes(new_params)
        format.html { redirect_to @record, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
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
  
  class OrganizationParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:organization).permit("internal_name", "status", "db_status", "activity", "info", "private_info", "established", "synonyms","synopsis","category",
                                             "new_images" => [], "remove_artist_organizations" => [], "remove_related_organizations" => [], "namehash" => params[:organization][:namehash].try(:keys),
                                             "new_references" => [:site_name => [], :url => []], "update_references" => [:site_name, :url], 
                                             :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:organization][:name_langs].try(:keys),
                                             :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:organization][:info_langs].try(:keys),
                                             :new_related_organizations => [:id => [], :category =>[]], :update_related_organizations => :category,
                                             :new_artists => [:id => [], :category => []], :update_artist_organizations => [:category]        
                                              )
      elsif current_user
        params.require(:organization).permit()
      else
        params.require(:organization).permit()
      end           
    end
  end
  
  private
    def organization_params
      OrganizationParams.filter(params,current_user)
    end
end
