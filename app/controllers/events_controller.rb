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
    @event = Event.find(params[:id])

    @albums = @event.albums.includes(:primary_images, :tags, :translations).filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])
    
    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.json {@fields = (params[:fields] || '').split(',')}
    end
  end
  
  def new
    @event = Event.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end
  
  def edit
    @event = Event.find(params[:id])    
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @event }
    end
  end
  
  def create
    respond_to do |format|
      if @event.full_save(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    @event = Event.find(params[:id])
    
    respond_to do |format|
      if @event.full_update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
end
