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
      @divid = params[:div_id]      
      #Check if query qualifies for autocomplete
      autocomplete = params[:autocomplete]
      if autocomplete.nil? == false
        @autocompletepath = "autocomplete_" + autocomplete + '_' + autocomplete.split('_')[0] + 's_path'
      end
      #Params for the fields_for name
      @fieldsfornames = params[:fields_for_names]
      #Parmams for if there's a model
      @fieldsforcats = params[:fields_for_cats]
      category_model = params[:category_model]
      category_constant = params[:category_constant]
      if category_model.nil? == false and category_constant.nil? == false
        @categories = category_model.constantize.const_get(category_constant)
      end
      #Check if this is a script function to add to all song fields
      if params[:script].nil? == false
        @songscript = []
        @defaultvalue = params[:script][:name]
        params[:script][:div_ids].split(',').each do |songid|
          songarray = {}
          songarray[:divid] = "#Sources" + songid.to_s
          songarray[:fields_for_names] = 'song[' + songid.to_s + '][newsourceids]'
          @songscript << songarray
        end
      end
    end  
    
    def add_related_model_form
      authorize! :edit, Album
      #This adds a self related model form, given some inputs
      #Params for the div ID/Class
      @divid = params[:div_id]      
      #Check if model qualifies for autocomplete
      autocomplete = params[:autocomplete]
      if autocomplete.nil? == false
        @autocompletepath = "autocomplete_" + autocomplete + '_' + autocomplete.split('_')[0] + 's_path'
      end
      #Params for category
      @fieldsforcats = params[:fields_for_cats]
      #Params for the fields_for name/id
      @fieldsfornamesorids = params[:fields_for_names_or_ids]
      #params for the model
      @model = params[:model]
      @relationships = @model.constantize::SelfRelationships
    end  
  
  #Misc.
    def well_toggle
      authorize! :show, Album
      @divid = params[:div_id]
      @toggleid = params[:toggle_id]
    end  
    
end
