class EventsController < ApplicationController
  load_and_authorize_resource
    
  def index
    @events = Event.all.sort_by { |e| e.shorthand }
  end
  
  def show
    @event = Event.find(params[:id])
  end
  
  def edit
    @event = Event.find(params[:id])    
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
