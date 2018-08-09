module NeoNodeModule #Attaches to mySQL models.
  extend ActiveSupport::Concern

  included do
    after_commit :neo_update
  end

  #Instance Methods

  def neo_model
    "Neo::#{self.class.name}".constantize
  end

  def neo_db_record
    neo_model.find_by(uuid: self.id)
  end

  def neo_record
    record = neo_db_record
    record = neo_model.new(neo_properties) if record.nil?
    record.albums = self.album.neo_record if self.class.name == "Song" && record.album == nil
    return record
  end

  private
    def neo_update
      record = neo_record
      unless record.new?
        properties = neo_properties
        db_properties = record.attributes.except("created_at","updated_at")
        db_properties.each {|k,v| properties[k] = nil if properties[k].blank?}
        record.attributes = properties
      end
      record.save
    end

    def neo_properties
      properties = {'uuid' => self.id}
      if self.respond_to?(:read_name)
        properties['name'] = self.read_name.first
      else
        properties['name'] = self.name
      end

      if self.class == Event
        properties['start_date'] = self.start_date
        properties['end_date'] = self.end_date
      end


      properties['references'] = self.references.map { |ref| ref.url } if self.respond_to?(:references)
      properties['image_id'] = self.primary_images.first.id if self.respond_to?(:images)


      properties.reject! {|k,v| v.blank?} #remove any blanks
      return properties
    end


end

