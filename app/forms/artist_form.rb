class ArtistForm < GeneralForm

  #Attribute accessors
  attr_accessor :references
  attr_accessor :translations
  attr_accessor :birth_date
  attr_accessor :debut_date
  attr_accessor :images #for deletion
  attr_accessor :new_images
  attr_accessor :taglists
  attr_accessor :self_relations
  attr_accessor :artist_organizations

  def initialize(attributes = {}) #if we need more than just basic assignment
    super attributes
    @record ||= Artist.new
    @references ||= @record.references
    @translations ||= @record.translations
    @images ||= @record.images
    @taglists ||= @record.taglists
    @birth_date ||= generate_date(@record,'birth_date')
    @debut_date ||= generate_date(@record,'debut_date')
    @self_relations ||= @record.related_artist_relations
    @artist_organizations ||= @record.artist_organizations
  end

  private
    def model
      Artist
    end

    def transaction
      manage_attributes(@record,@attribute_record)
      manage_references(@record,@references) unless @references.blank?
      manage_translations(@record,@translations,[:name,:info]) unless @translations.blank?
      manage_taglists(@record,@taglists) unless @taglists.blank?
      manage_images(@record,@images) unless @images.blank?
      manage_self_associations(@record,@self_relations) unless @self_relations.blank?
      manage_association(@record,@artist_organizations,'organization','artist') unless @artist_organizations.blank?
    end

    def manage_attributes(record,attribute_record)
      handle_date(attribute_record,:debut_date,@debut_date) #modify date before assigning
      handle_date(attribute_record,:birth_date,@birth_date) #modify date before assigning
      @attribute_record.namehash = eval(@attribute_record.namehash) if @attribute_record.namehash.is_a?(String) #converts string back into hash
      record.update_attributes!(@attribute_record.slice(:internal_name,:synonyms,:status,:db_status,
                                                        :activity,:category,:birth_date,:birth_date_bitmask,
                                                        :debut_date,:debut_date_bitmask,
                                                        :synopsis,:namehash,:private_info))
      add_to_log(record)
    end


end