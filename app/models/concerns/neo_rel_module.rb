module NeoRelModule #Attaches to mySQL join models
  extend ActiveSupport::Concern

  included do
    after_commit :neo_update
    after_destroy_commit :neo_destroy
  end

  #Instance Methods
  def neo_model
    if self.class.name.starts_with?('Related')
      Neo::RelatedRecord
    else
      "Neo::#{self.class.name}".constantize
    end
  end

  private
    def neo_update
      unless self.class == Taglist && self.subject.class == Post
        rel = neo_relation
        unless rel.from_node.sql_record.nil? || rel.to_node.sql_record.nil? #sql record is deleted. don't create.
          unless rel.new? #compare neo rel attributes with properties and remove the missing. aka update.
            properties = neo_properties
            db_properties = rel.attributes.except('created_at','updated_at')
            db_properties.each {|k,v| properties[k] = nil if properties[k].blank?}
            rel.attributes = properties
          end
          rel.save
        end
      end
    end

    def neo_db_rel(from_model,to_models)
      self.send(from_model).neo_record.send(to_models).each_rel.select  { |r| r.uuid == self.id }.first
    end

    def neo_rel(from,to)
      if from.class == to.class #Related record
        rel = neo_db_rel("#{from.class.name.downcase}1","#{from.class.name.downcase}_relations")
      else
        rel = neo_db_rel(from.class.name.downcase,to.class.name.downcase.pluralize)
      end
      if rel.nil? #create a rel
        rel = self.neo_model.new(from_node: from.neo_record, to_node: to.neo_record)
        rel.attributes = neo_properties
      end
      return rel
    end

    def neo_properties
      properties = {'uuid' => self.id}

      if self.class == ArtistAlbum || self.class == ArtistSong #Performers
        Artist.get_credits(self.category).each do |cat|
          if cat.starts_with?('Feat')
            properties[cat[4..-1]] = 'featured'
          else
            properties[cat] = 'yes'
          end
        end
        properties['Credited as'] = self.read_display_name.first
      end

      if self.class == ArtistOrganization #Members/Label/Founder
        unless self.category.nil?
          if self.category.starts_with?('Former ')
            properties[self.category[7..-1]] = 'Former'
          else
            properties[self.category] = 'yes'
          end
        end
      end

      if self.class == SongSource
        properties['Usage'] = self.classification
        properties['Episode Numbers'] = self.ep_numbers
        properties["#{self.classification} #"] = self.op_ed_number if self.classification == 'OP' || self.classification == 'ED'
      end

      properties['Appeared As A'] = self.category if self.class == SourceSeason
      properties['Company Role'] = self.category if self.class == AlbumOrganization || self.class == SourceOrganization
      properties['Relationship'] = self.category if self.class.name.starts_with?('Related')

      properties.reject! {|k,v| v.blank?} #remove any blanks
      return properties
    end

    def neo_destroy
      neo_relation.destroy #will destroy new and saved_to_db records, which is fine.
    end
end

