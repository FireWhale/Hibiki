class OrganizationsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  include GenViewsModule
  include ImageViewModule

  def create
    @form = OrganizationForm.new(organization_params)

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice: "#{@form.record.class} was successfully created." }
        format.json { render json: @form.record, status: :created, location: @form.record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @form = OrganizationForm.new(organization_params.merge(record: Organization.find(params[:id])))

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice:  "#{@form.record.class} was successfully updated." }
        format.json { head :no_content }
      else
        @record = @form.record.class.find(params[:id])
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
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
      if current_user && current_user.abilities.include?('Admin')
        #Make sure params[:id] matches
        params.require(:organization_form).permit!
      elsif current_user
        params.require(:organization_form).permit()
      else
        params.require(:organization_form).permit()
      end           
    end
  end
  
  private
    def organization_params
      OrganizationParams.filter(params,current_user)
    end
end
