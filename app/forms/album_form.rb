class AlbumForm < GeneralForm

  #Attribute accessors
  attr_accessor :references
  attr_accessor :translations
  attr_accessor :release_date
  attr_accessor :images #for deletion
  attr_accessor :new_images
  attr_accessor :taglists
  attr_accessor :self_relations
  attr_accessor :album_events
  attr_accessor :artist_albums
  attr_accessor :album_sources
  attr_accessor :album_organizations
  attr_accessor :song_forms

  def initialize(attributes = {}) #if we need more than just basic assignment
    super attributes
    @record ||= Album.new
    @references ||= @record.references
    @translations ||= @record.translations
    @images ||= @record.images
    @taglists ||= @record.taglists
    @release_date ||= generate_date(@record,'release_date')
    @album_events ||= @record.album_events
    @self_relations ||= @record.related_album_relations
    @artist_albums ||= @record.artist_albums
    @album_sources ||= @record.album_sources
    @album_organizations ||= @record.album_organizations
    @song_forms ||= @record.songs.map { |s| SongForm.new(record: s) }
  end

  def song_forms_attributes=(attributes)
    @song_forms ||= []
    attributes.each do |k, song_form_att|
      @song_forms.push(SongForm.new(song_form_att.merge(record: Song.new(id: song_form_att[:record_attributes][:id])))) #Add in dummy record to search on
    end
  end

  private
  def model
    Album
  end

  def transaction
    manage_attributes(@record,@attribute_record)
    manage_references(@record,@references) unless @references.blank?
    manage_translations(@record,@translations,[:name,:info]) unless @translations.blank?
    manage_taglists(@record,@taglists) unless @taglists.blank?
    manage_images(@record,@images) unless @images.blank?
    manage_self_associations(@record,@self_relations) unless @self_relations.blank?
    manage_association(@record,@album_events,'event','album') unless @album_events.blank?
    manage_artist_association(@record,@artist_albums,'album') unless @artist_albums.blank?
    manage_association(@record,@album_sources,'source','album') unless @album_sources.blank?
    manage_association(@record,@album_organizations,'organization','album') unless @album_organizations.blank?
    manage_songs(@record,@song_forms) unless @song_forms.blank? #artists and sources added here overwrite previous removals
  end

  def manage_attributes(record,attribute_record)
    handle_date(attribute_record,:release_date,@release_date) #modify date before assigning
    @attribute_record.namehash = eval(@attribute_record.namehash) if @attribute_record.namehash.is_a?(String) #converts string back into hash
    record.update_attributes!(@attribute_record.slice(:internal_name,:catalog_number,:synonyms,:status,
                                                      :classification,:release_date,:release_date_bitmask,
                                                      :namehash,:private_info))
    add_to_log(record)
  end

  def manage_songs(record,song_forms)
    song_forms.each do |song_form|
      # Replace record with a song that's from the album. Or a blank Song
      # If the record's id doesn't match, it will not pass.
      song_form.record = record.songs.find_by_id(song_form.record.id) || Song.new
      if song_form.save
        song_form.record.update_attributes!(album: record) if song_form.record.album.blank? #add album_id if blank
        song_form.record.update_attributes!(record.slice(:release_date, :release_date_bitmask)) if song_form.record.release_date.blank?  && song_form.record.release_date_bitmask.blank?
        add_to_log(song_form.record)
      end
    end
  end


end