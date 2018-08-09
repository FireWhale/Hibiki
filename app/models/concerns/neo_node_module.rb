module NeoNodeModule #Attaches to mySQL models.
  extend ActiveSupport::Concern

  included do
    after_commit :neo_update
    after_destroy_commit :neo_destroy
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
    record.albums = self.album.neo_record if self.class == Song && record.album == nil
    return record
  end

  private
    def neo_update
      unless self.destroyed?
        record = neo_record
        unless record.new?
          properties = neo_properties
          db_properties = record.attributes.except('created_at','updated_at')
          db_properties.each {|k,v| properties[k] = nil if properties[k].blank?}
          record.attributes = properties
        end
        record.save
      end
    end

    def neo_properties
      properties = {'uuid' => self.id}
      if self.respond_to?(:read_name)
        properties['name'] = self.read_name.first
      else
        properties['name'] = self.name
      end

      if self.class == Album
        properties['catalog number'] = self.catalog_number
      end

      if self.class == Song
        properties['track number'] = self.track_number
        properties['disc number'] = self.track_number
        properties['duration'] = self.length
        properties['lyrics'] = self.read_lyrics.first
      end

      if self.class == Artist
        properties['birth place'] = self.birth_place
        properties['blood type'] = self.blood_type
        properties['gender'] = self.gender
        properties['debut date'] = self.debut_date_formatted
        properties['birth date'] = self.birth_date_formatted
        properties['type of artist'] = self.category
      end

      if self.class == Source
        properties['end date'] = self.end_date_formatted
        properties['plot summary'] = self.plot_summary
      end

      if self.class == Organization
        properties['established'] = self.established_formatted
        properties['type of org'] = self.category
      end

      if self.class == Event || self.class == Season
        properties['start date'] = self.start_date
        properties['end date'] = self.end_date
      end

      if self.class == Event
        properties['abbreviation'] = self.read_abbreviation.first
        properties['shorthand'] = self.shorthand
      end

      properties['info'] = self.read_info.first if self.respond_to?(:read_info)
      properties['activity'] = self.activity if self.respond_to?(:activity)
      properties['release date'] = self.release_date_formatted if self.respond_to?(:release_date_formatted)
      properties['synopsis'] = self.synopsis if self.respond_to?(:synopsis)
      properties['references'] = self.references.map { |ref| ref.url } if self.respond_to?(:references) && self.references.blank? == false
      properties['image_id'] = self.primary_images.first.id if self.respond_to?(:images) && self.primary_images.blank? == false

      properties.reject! {|k,v| v.blank?} #remove any blanks
      return properties
    end

    def neo_destroy
      neo_db_record.destroy unless neo_db_record.nil?
    end
end

