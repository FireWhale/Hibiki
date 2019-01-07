class SongForm < GeneralForm

  #Attribute accessors
  attr_accessor :references
  attr_accessor :translations
  attr_accessor :release_date
  attr_accessor :images #for deletion
  attr_accessor :new_images
  attr_accessor :taglists
  attr_accessor :self_relations
  attr_accessor :artist_songs
  attr_accessor :song_sources

  def initialize(attributes = {}) #if we need more than just basic assignment
    super attributes
    @record ||= Song.new
    @references ||= @record.references
    @translations ||= @record.translations
    @images ||= @record.images
    @taglists ||= @record.taglists
    @release_date ||= generate_date(@record,'release_date')
    @self_relations ||= @record.related_song_relations
    @artist_songs ||= @record.artist_songs
    @song_sources ||= @record.song_sources
  end

  private
  def model
    Song
  end

  def transaction
    manage_attributes(@record,@attribute_record) unless @attribute_record.blank? #if blank, direct attributes aren't updated
    manage_references(@record,@references) unless @references.blank?
    manage_translations(@record,@translations,[:name,:info]) unless @translations.blank?
    manage_taglists(@record,@taglists) unless @taglists.blank?
    manage_images(@record,@images) unless @images.blank?
    manage_self_associations(@record,@self_relations) unless @self_relations.blank?
    manage_artist_association(@record,@artist_songs,'song') unless @artist_songs.blank?
    manage_association(@record,@song_sources,'source','song') unless @song_sources.blank?
  end

  def manage_attributes(record,attribute_record)
    handle_date(attribute_record,:release_date,@release_date) #modify date before assigning
    format_track_number(attribute_record)
    #handle_length?
    @attribute_record.namehash = eval(@attribute_record.namehash) if @attribute_record.namehash.is_a?(String) #converts string back into hash
    record.update_attributes!(@attribute_record.slice(:internal_name,:synonyms,:status,:release_date,:release_date_bitmask,
                                                      :track_number,:disc_number,:length,
                                                      :namehash,:private_info))
    add_to_log(record)
  end

  def format_track_number(attribute_record)
    track_number = attribute_record.track_number
    unless track_number.nil?
      if track_number.include?(".")
        attribute_record.disc_number = track_number.split(".")[0]
        attribute_record.track_number = track_number.split(".")[1]
      end
      #don't add a leading zero to the number.
      #attribute_record.track_number =  attribute_record.track_number.rjust(2,'0') if attribute_record.track_number.length < 2
    end
  end

  def format_length(input_length)
    output = nil
    if input_length.include?(":") && input_length.count(":") == 1
      output = input_length.split(":")[0].to_i * 60 + input_length.split(":")[1].to_i
    elsif input_length.to_i.to_s == input_length.sub(/^[0]+/,"")
      output = input_length.to_i
    end
    return output
  end

end