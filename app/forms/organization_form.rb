class OrganizationForm < GeneralForm

  #Attribute accessors
  attr_accessor :references
  attr_accessor :translations
  attr_accessor :established
  attr_accessor :images #for deletion
  attr_accessor :new_images
  attr_accessor :taglists
  attr_accessor :self_relations
  attr_accessor :artist_organizations

  def initialize(attributes = {}) #if we need more than just basic assignment
    super attributes
    @record ||= Organization.new
    @references ||= @record.references
    @translations ||= @record.translations
    @images ||= @record.images
    @taglists ||= @record.taglists
    @established ||= generate_date(@record,'established')
    @self_relations ||= @record.related_organization_relations
    @artist_organizations ||= @record.artist_organizations
  end

  private
    def model
      Organization
    end

    def transaction
      manage_attributes(@record,@attribute_record)
      manage_references(@record,@references) unless @references.blank?
      manage_translations(@record,@translations,[:name,:info]) unless @translations.blank?
      manage_taglists(@record,@taglists) unless @taglists.blank?
      manage_images(@record,@images) unless @images.blank?
      manage_self_associations(@record,@self_relations) unless @self_relations.blank?
      manage_association(@record,@artist_organizations,'artist','organization') unless @artist_organizations.blank?
    end

    def manage_attributes(record,attribute_record)
      handle_date(attribute_record,:established,@established) #modify date before assigning
      #Make sure record_attributes id (can be modified by user) matches passed_in_record's id (cannot be modified)
      if attribute_record.id == record.id && attribute_record.class == record.class
        @attribute_record.namehash = eval(@attribute_record.namehash) if @attribute_record.namehash.is_a?(String) #converts string back into hash
        record.update_attributes!(@attribute_record.slice(:internal_name,:synonyms,:status,:db_status,
                                                          :activity,:category,:established,:established_bitmask,
                                                          :synopsis,:namehash,:private_info))
        add_to_log(record)
      end
    end


end