class ScriptsController < ApplicationController
  #This scripts controller is for managing cross-model scripts
  #Example: Well toggle, lots of pages use well toggle.
  #Not Included: Image toggle, since that only uses Images
 
  #Used for sorting/adding albums to Album list on seasons/watchlist
    def toggle_albums
      if params[:source_id].nil? == false
        record = Source.includes({albums: [:collections, :primary_images]}).find(params[:source_id])
      elsif params[:artist_id].nil? == false
        record = Artist.includes({albums: [:collections, :primary_images]}).find(params[:artist_id])
      elsif params[:organization_id].nil? == false
        record = Organization.includes({albums: [:collections, :primary_images]}).find(params[:organization_id])
      end
      
      if record.nil? == false
        #We need to build two things to send. Album IDs and the flag to watch for.
        @albums = record.albums
        @flag =  record.class.to_s[0].downcase + record.id.to_s
      end
      
      respond_to do |format|
        if record.nil? == false
          format.html {redirect_to record }
        end    
        format.js
      end
        
    end
    
    def sort_albums
      #Types of sorts:
      #1. Date (week, month)
      #2. Title? 
      @sort = params[:sort]
      ids = params[:ids]
      if ids.nil? == false
        ids = ids.split('|')
        @albums = Album.find(ids) 
      end
      
      respond_to do |format|
        format.js
      end      
    end
    
    def filter_albums
      #Types of Filters
      #Collected/Ignored
      #Limited Editions
      #Tags?
      if params[:filters].nil? == false
        @filters = params[:filters].join(" ")
      end
    end
  

  #These methods help modularize the js adding forms for edit views.
    def add_reference_form
      authorize! :edit, Album
      #This adds a reference form. @string is the params hash string the form should be under
      @fieldsfor = params[:fields_for]
    end
  
    def add_model_form
      authorize! :edit, Album
      #This adds a relational model with a category
      #Params for the div ID/Class it should be attached to
        @parent_div = params[:parent_div]      
      #Check if query qualifies for autocomplete
        autocomplete = params[:autocomplete_path]
        @autocomplete_path = "autocomplete_" + autocomplete + '_' + autocomplete.split('_')[0] + 's_path' unless autocomplete.nil?
      #Fields_for names
        @field_names = params[:field_names]
        #If text_area is flagged, use a text area instead of text_field
        @text_area_field_names = params[:text_area_field_names]
      #Category list names
        @category_field_names = params[:category_field_names]
        @categories = params[:category_select]
        @categories = @categories.split("::")[0].constantize.const_get(categories.split("::")[1]) if @categories.class == String
      #Get the label if there is one passed in
        @label = (params[:label].nil? ? "ID:" : params[:label]) 
      #Get the default value if there is one passed in
        @default_value = params[:default_value] unless params[:default_value].nil?
      #Get a self-relationship flag if one is passed in
        @self_relationship_model = params[:self_relationship_model]
        @label = "" unless @self_relationship_model.nil?
      #Get a artist_categories if one is passed in
        @artist_category_names = params[:artist_category_names] 
      #Get track info for songs
        @song_info = params[:song_info]
      #Get song_source model
        @song_source = params[:song_source]
      #Check if this is a script function to add to all song fields
      if params[:script].nil? == false
        @songscript = []
        @default_value = params[:script][:name]
        params[:script][:div_ids].split(',').each do |songid|
          songarray = {}
          songarray[:divid] = "#Sources" + songid.to_s
          songarray[:fields_for_names] = 'song[' + songid.to_s + '][newsourceids]'
          @songscript << songarray
        end
      end
    end  
    
  
  #Misc.
    def well_toggle
      authorize! :show, Album
      @divid = params[:div_id]
      @toggleid = params[:toggle_id]
    end  
    
end
