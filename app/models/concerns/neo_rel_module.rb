module NeoRelModule #Attaches to mySQL join models
  extend ActiveSupport::Concern

  included do
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

  private
    def neo_rel(from,to) #generates the relation
      if self.class.name.start_with?('Related') #Related record
        model_name = self.class.name[7..-1].chomp('s').downcase
        rel = neo_db_rel("#{model_name}1","#{model_name}_relations")
      else
        rel = neo_db_rel(from.class.name.downcase,to.class.name.downcase.pluralize)
      end
      if rel.nil? #create a rel
        rel = self.neo_model.new
        rel.from_node = from.neo_record unless from.nil?
        rel.to_node = to.neo_record unless to.nil?
        rel.attributes = neo_properties
      end
      return rel
    end

    def neo_db_rel(from_model,to_models)
      from_record = self.send(from_model)
      return from_record.nil? ? nil :  from_record.neo_record.send(to_models).each_rel.select  { |r| r.uuid == self.id }.first
    end

    def neo_destroy #will destroy new and saved_to_db records, which is fine.
      neo_relation.destroy unless self.class == Taglist && self.subject.class == Post
    end
end

