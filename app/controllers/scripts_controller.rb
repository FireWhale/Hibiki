class ScriptsController < ApplicationController
  #This scripts controller is for managing cross-model scripts
  #Example: Well toggle, lots of pages use well toggle.
  #Not Included: Image toggle, since that only uses Images
 
  def toggle_albums #Used for sorting/adding albums to Album list on seasons/watchlist
    #Check for all albums flag
    if params[:all_albums] == "true"
      @albums = Album.includes(:collections).where(nil)
    else #Get the aos values
      aos = params[:aos]
      aos = "" if  aos.nil? 
      aos_hash = aos.split(",").group_by {|a| a[0] }
      artist_ids = ( aos_hash["a"].nil? ? nil : aos_hash["a"].map! {|each| each[1..-1]} ) 
      organization_ids = ( aos_hash["o"].nil? ? nil : aos_hash["o"].map! {|each| each[1..-1]} ) 
      source_ids = ( aos_hash["s"].nil? ? nil : aos_hash["s"].map! {|each| each[1..-1]} ) 
      @albums = Album.includes(:collections).artist_organization_source(artist_ids, organization_ids, source_ids)
      # not used - @total_count = Album.artist_organization_source(artist_ids, organization_ids, source_ids).count
    end
    #Get the date
    date_begin = params[:date1]
    date_end = params[:date2]
    unless date_begin.nil? || date_begin.empty? || date_end.nil? || date_end.empty?
      start_date = Date.new( 1970 + (date_begin.to_i / 12), (date_begin.to_i % 12) + 1)
      end_date = Date.new( 1970 + (date_end.to_i / 12), (date_end.to_i % 12) + 1).to_time.advance(months: 1).to_date - 1
      @albums = @albums.date_range(start_date, end_date)
    end
    #Get the collection values
    col = params[:col]
    unless col.nil? || col.empty?
      col = col.split(",").map { |a| a == "N" ? "N" : Collection::Relationship[a.to_i] }
      if col.include?("N")
        @albums = @albums.col(current_user.id,col) #This unions the collections and non-collected
      else
        @albums = @albums.collections(current_user.id, col)
      end
    end
    #Get the release values
    rel = params[:rel]
    unless rel.nil? || rel.empty?
      rel = rel.split(",").map { |a| a == "N" ? "N" : ["Limited Edition", "Reprint"][a.to_i] }
      if rel.include?("N")
        @albums = @albums.album_cats(rel) #This unions the categories and none-categories
      else
        @albums = @albums.album_categories(rel)
      end        
    end
    #Get the tag values
    tag = params[:tag]
    unless tag.nil? || tag.empty?
      tag = tag.split(",")
      @albums = @albums.filter_by_tag(tag)
    end
    
    #Sort? Popularity, Release Date 
    if ["Week","Month","Year"].include?(params[:sort])
      @sort = params[:sort].downcase      
    else
      @sort = "year"
    end
    
    respond_to do |format|
      format.js
      format.json { render :json => @albums }
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
    end  
    
  
  #Misc.
    def well_toggle
      authorize! :show, Album
      @divid = params[:div_id]
      @toggleid = params[:toggle_id]
    end  
    
end
