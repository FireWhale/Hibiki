class SourceForm < GeneralForm

  #Attribute accessors
  attr_accessor :references
  attr_accessor :translations
  attr_accessor :release_date
  attr_accessor :end_date
  attr_accessor :images #for deletion
  attr_accessor :new_images
  attr_accessor :taglists
  attr_accessor :self_relations
  attr_accessor :source_organizations

  def initialize(attributes = {}) #if we need more than just basic assignment
    super attributes
    @record ||= Source.new
    @references ||= @record.references
    @translations ||= @record.translations
    @images ||= @record.images
    @taglists ||= @record.taglists
    @release_date ||= generate_date(@record,'release_date')
    @end_date ||= generate_date(@record,'end_date')
    @self_relations ||= @record.related_source_relations
    @source_organizations ||= @record.source_organizations
  end

  private
    def model
      Source
    end

    def transaction
      manage_attributes(@record,@attribute_record)
      manage_references(@record,@references) unless @references.blank?
      manage_translations(@record,@translations,[:name,:info]) unless @translations.blank?
      manage_taglists(@record,@taglists) unless @taglists.blank?
      manage_images(@record,@images) unless @images.blank?
      manage_self_associations(@record,@self_relations) unless @self_relations.blank?
      manage_association(@record,@source_organizations,'organization','source') unless @source_organizations.blank?
    end

    def manage_attributes(record,attribute_record)
      handle_date(attribute_record,:release_date,@release_date) #modify date before assigning
      handle_date(attribute_record,:end_date,@end_date) #modify date before assigning
      @attribute_record.namehash = eval(@attribute_record.namehash) if @attribute_record.namehash.is_a?(String) #converts string back into hash
      record.update_attributes!(@attribute_record.slice(:internal_name,:synonyms,:status,:db_status,
                                                        :activity,:category,:release_date,:release_date_bitmask,
                                                        :end_date,:end_date_bitmask,
                                                        :synopsis,:plot_summary,:namehash,:private_info))
      add_to_log(record)
    end


end