class ScriptsController < ApplicationController
  #This scripts controller is for managing cross-model scripts
  #Example: Well toggle, lots of pages use well toggle.
  #Not Included: Image toggle, since that only uses Images

  def toggle_albums #Used for sorting/adding albums to Album list on seasons/watchlist
    authorize! :show, Album
    #Get the aos values
    aos = params[:aos]
    aos = "" if  aos.nil?
    aos_hash = aos.split(",").group_by {|a| a[0] }
    artist_ids = ( aos_hash["a"].nil? ? nil : aos_hash["a"].map! {|each| each[1..-1]} )
    organization_ids = ( aos_hash["o"].nil? ? nil : aos_hash["o"].map! {|each| each[1..-1]} )
    source_ids = ( aos_hash["s"].nil? ? nil : aos_hash["s"].map! {|each| each[1..-1]} )
    if params[:all_albums] == "true" #Check for all albums flag
      @albums = Album.where(nil)
    elsif artist_ids.nil? && organization_ids.nil? && source_ids.nil?
      #Don't want to alter base functionality where
      #all nil automatically returns all results.
      #However, we want all nil to return no results. thus:
      @albums = Album.none
    else
      albums = Album.with_artist_organization_source(artist_ids, organization_ids, source_ids)
      @albums = albums.nil? ? Album.none : albums.distinct
    end

    #Get the release values
    rel = params[:rel]
    unless rel.blank?
      rel = rel.split(",").map { |a| a == "N" ? "N" : ["Limited Edition", "Reprint"][a.to_i] }
      if rel.include?("N")
        @albums = @albums.without_self_relation_categories(["Limited Edition", "Reprint"] - rel) #This unions the categories and none-categories
      else
        @albums = @albums.with_self_relation_categories(rel)
      end
    end

    #Get the date
    date_begin = params[:date1]
    date_end = params[:date2]
    unless date_begin.blank? || date_end.blank?
      start_date = Date.new( 1970 + (date_begin.to_i / 12), (date_begin.to_i % 12) + 1)
      end_date = Date.new( 1970 + (date_end.to_i / 12), (date_end.to_i % 12) + 1).to_time.advance(months: 1).to_date - 1
      @albums = @albums.in_date_range(start_date, end_date)
    end

    #Get the collection values
    col = params[:col]
    unless col.blank? || current_user.nil?
      col = col.split(",").map { |a| a == "N" ? "N" : Collection::Relationship[a.to_i] }
      if col.include?("N")
        @albums = @albums.not_in_collection(current_user.id, Collection::Relationship - col) #This unions the collections and non-collected
      else
        @albums = @albums.in_collection(current_user.id, col)
      end
    end

    #Get the tag values
    tags = params[:tag]
    unless tags.blank?
      tags = tags.split(",")
      @albums = @albums.with_tag(tags)
    end

    #Sort? Popularity, Release Date
    if ["Week","Month","Year"].include?(params[:sort])
      @sort = params[:sort].downcase
    else
      @sort = "year"
    end

    respond_to do |format|
      format.js
      format.json { render :json => @albums.to_json(:user => current_user) }
    end
  end

  def autocomplete
    authorize! :show, Album

    @json_results = []

    unless params[:term].blank?
      if params[:model].blank? #Use general search - all models
        search = Sunspot.search([Album, Artist, Organization, Source, Song]) do
          [Album, Artist, Organization, Source, Song].each do |model|
            data_accessor_for(model).include = :translations
          end
          any do
            fulltext params[:term] do
              #When we include autocomplete_edit, we inherently boost our translated fields
              fields(:autocomplete_search, :autocomplete_edit)
            end
            if params[:term].include?('*') || params[:term].include?('?')
              fulltext "\"#{params[:term]}\"" do
                fields(:autocomplete_search, :autocomplete_edit)
              end
            end
          end
          paginate page: 1, per_page: 10
        end
        @json_results = search.results.to_json({autocomplete: 'search', autocomplete_user: current_user})
      else
        #if a model is passed in, it's likely going to be for editing.
        search = params[:model].capitalize.constantize.search(:include => :translations) do
          fulltext params[:term] do
            fields(:autocomplete_edit)
          end
          paginate page: 1, per_page: 10
        end
        @json_results = search.results.to_json({autocomplete: 'edit', autocomplete_user: current_user})
      end
    end
    #I only need the term and the model ->

    #Get the right json format
    respond_to do |format|
      format.json { render :json => @json_results }
      format.js { render :json => @json_results}
    end
  end


  #These methods help modularize the js adding forms for edit views.
    def add_model_form
      authorize! :edit, Album
      #This adds a relational model with a category
      #Params for the div ID/Class it should be attached to
        #Needs one of two necessary params:
        @parent_div = params[:parent_div]
        @parent_divs = params[:parent_divs].split(',') unless params[:parent_divs].nil?
      #Check if query qualifies for autocomplete
        @autocomplete_model = params[:autocomplete_model] unless params[:autocomplete_model].nil?
      #Fields_for names
        @field_names = params[:field_names]
        @field_class = params[:field_class]
        #If text_area is flagged, use a text area instead of text_field
        @text_area_field_names = params[:text_area_field_names]
      #Category list names
        @category_field_names = params[:category_field_names]
        @categories = params[:category_select]
        @categories = @categories.split("::")[0].constantize.const_get(categories.split("::")[1]) if @categories.class == String
      #Secondary category list names
        @secondary_category_field_names = params[:secondary_category_field_names]
        @secondary_categories = params[:secondary_category_select]
        @secondary_label = (params[:secondary_label].nil? ? "ID:" : params[:secondary_label])
       #Get the label if there is one passed in
        @label = (params[:label].nil? ? "ID:" : params[:label])
      #Get the default value if there is one passed in
        @default_value = params[:default_value] unless params[:default_value].nil?
      #Get a self-relationship flag if one is passed in
        @self_relationship_model = params[:self_relationship_model]
        @label = "" unless @self_relationship_model.nil?
      #Get the display_name for artistalbums/artistsongs if one is passed in
        @artist_display_names = params[:artist_display_names]
      #Get a artist_categories if one is passed in
        @artist_category_names = params[:artist_category_names]
      #Get track info for songs
        @song_info = params[:song_info]
      #Get song_source model
        @song_source = params[:song_source]

      respond_to do |format|
        format.js
      end
    end

    def add_tag
      authorize! :edit, Tag

      tag = Tag.find_by_id(params[:tag_id])
      record = params[:subject_type].constantize.find(params[:subject_id])

      #For locating the div on a js response
      @record_id = params[:subject_id]
      @tag_id = params[:tag_id]

      unless tag.nil? || record.nil?
        taglist = Taglist.new(tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s)
      else
        taglist = Taglist.new
      end

      respond_to do |format|
        if taglist.save
          format.html { redirect_to record, notice: "Successfully added tag"}
          format.js { @msg = "Added" }
        else
          format.html { redirect_to record, notice: "FAILED: #{taglist.errors.full_messages.join(", ")}"}
          format.js { @msg = "Failed #{taglist.errors.full_messages.join(", ")}" }
        end
      end
    end

    def remove_tag
      authorize! :edit, Tag
      taglist = Taglist.where(:tag_id => params[:tag_id], :subject_id => params[:subject_id], :subject_type => params[:subject_type]).first

      @record_id = params[:subject_id]
      @tag_id = params[:tag_id]

      record = params[:subject_type].constantize.find(params[:subject_id])

      respond_to do |format|
        unless taglist.nil?
          format.html {taglist.destroy
                       redirect_to record, notice: "Successfully removed tag"}
          format.js { taglist.destroy
                      @msg = "Removed"}
        else
          format.html { redirect_to record, notice: "Failed to locate taglist"}
          format.js { @msg = "Failed to locate taglist"}
        end
      end
    end

  #Misc.
    def well_toggle
      authorize! :edit, Album
      @div_id = params[:div_id]
      @toggle_id = params[:toggle_id]

      respond_to do |format|
        format.js
      end
    end

end
