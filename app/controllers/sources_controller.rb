class SourcesController < ApplicationController
  load_and_authorize_resource
  include GenViewsModule
  include ImageViewModule

  def create
    @form = SourceForm.new(source_params)
    
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
    @form = SourceForm.new(source_params.merge(record: Source.find(params[:id])))

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice:  "#{@form.record.class} was successfully updated." }
        format.json { head :no_content }
      else
        @record = Organization.find(params[:id])
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
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
      if current_user && current_user.abilities.include?('Admin')
        params.require(:source).permit!
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
