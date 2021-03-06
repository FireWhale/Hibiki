class EventsController < ApplicationController
  load_and_authorize_resource
    
  def index
    @events = Event.includes(:translations).order(:start_date)
  
    respond_to do |format|
      format.html # index.html.erb
      format.json   
    end
  end
  
  def show
    @record = Event.find(params[:id])

    @albums = @record.albums.includes(:primary_images, :tags, :translations).filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])
    
    respond_to do |format|
      format.js {render file: 'shared/show' }
      format.html # show.html.erb
      format.json do
        @fields = (params[:fields] || '').split(',')
        render file: 'shared/show'
      end
    end
  end
  
  def new
    @record = Event.new
    
    respond_to do |format|
      format.html  { render file: 'shared/new', layout: 'full'}
      format.json { render json: @record }
    end
  end
  
  def edit
    @record = Event.find(params[:id])
    
    respond_to do |format|
      format.html { render file: 'shared/edit', layout: 'full'}
      format.json { render json: @record }
    end
  end
  
  def create
    @record = Event.new(event_params)
    
    respond_to do |format|
      if @record.save
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Event was successfully created.' }
        format.json { render json: @record, status: :created, location: @record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    @record = Event.find(params[:id])
    
    respond_to do |format|
      if @record.update_attributes(event_params)
        NeoWriter.perform(@record,1)
        format.html { redirect_to @record, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
  
  class EventParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:event).permit("internal_name", "shorthand", "db_status", "start_date", "end_date",
                                      :new_references => [:site_name => [], :url => []], :update_references => [:site_name, :url],
                                      :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:event][:name_langs].try(:keys),
                                      :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:event][:info_langs].try(:keys),
                                      :new_abbreviation_langs => [], :new_abbreviation_lang_categories => [], :abbreviation_langs => params[:event][:abbreviation_langs].try(:keys))
      elsif current_user
        params.require(:event).permit()
      else
        params.require(:event).permit()
      end          
    end
  end
  
  private
    def event_params
      EventParams.filter(params,current_user)
    end  
end
