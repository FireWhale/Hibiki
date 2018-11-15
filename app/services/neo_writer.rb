class NeoWriter
  include Performable

  def initialize(record,depth = 0)
    @record = record
    @depth = depth
    @recordlist = [record]
  end

  def perform
    unless @record.class == Tag && @record.visibility != 'Any'
      if neo_update(@record) && @depth > 0
        neo_related_models_crawl(@record,@depth)
        neo_relations_crawl(@record)
      end
    end
  end

  private
    def neo_update(record)
      if record.persisted?
        neo_record = record.neo_record
        unless neo_record.new?
          properties = record.neo_properties
          db_properties = neo_record.attributes.except('created_at','updated_at')
          db_properties.each {|k,v| properties[k] = nil if properties[k].blank?}
          neo_record.attributes = properties
        end
        neo_record.save
      end
    end

    def neo_related_models_crawl(record,depth) #saves connected models
      relationships = default_relationships(record.class)
      relationships.keys.each do |model|
        record.send(model).each do |linked|
          NeoWriter.perform(linked,depth - 1)
        end
      end
    end

    def neo_relations_crawl(record)
      relationships = default_relationships(record.class)
      relationships.values.uniq.each do |join_model|
        unless join_model.nil?
          record.send(join_model).each do |join_record|
            neo_rel_update(join_record)
          end
        end
      end
    end

    def neo_rel_update(relation)
      unless relation.class == Taglist && relation.subject.class == Post
        rel = relation.neo_relation
        unless rel.from_node.respond_to?(:set?) || rel.to_node.respond_to?(:set?) #if true, they aren't real nodes.
          unless rel.from_node.sql_record.nil? || rel.to_node.sql_record.nil? #sql record is deleted. don't create.
            unless rel.new? #compare neo rel attributes with properties and remove the missing. aka update.
              properties = relation.neo_properties
              db_properties = rel.attributes.except('created_at','updated_at')
              db_properties.each {|k,v| properties[k] = nil if properties[k].blank?}
              rel.attributes = properties
            end
            rel.save
          end
        end
      end
    end

    def default_relationships(record_class) #saves join records between models
      relations = {}
      if record_class == Album
        relations[:related_albums] = 'related_album_relations'
        relations[:artists] = 'artist_albums'
        relations[:organizations] = 'album_organizations'
        relations[:sources] = 'album_sources'
        relations[:songs] = nil
        relations[:events] = 'album_events'
        relations[:tags] = 'taglists'
      elsif record_class == Artist
        relations[:albums] = 'artist_albums'
        relations[:related_artists] = 'related_artist_relations'
        relations[:organizations] = 'artist_organizations'
        relations[:songs] = 'artist_songs'
        relations[:tags] = 'taglists'
      elsif record_class == Organization
        relations[:albums] = 'album_organizations'
        relations[:artists] = 'artist_organizations'
        relations[:related_organizations] = 'related_organization_relations'
        relations[:sources] = 'source_organizations'
        relations[:tags] = 'taglists'
      elsif record_class == Source
        relations[:albums] = 'album_sources'
        relations[:related_sources] = 'related_source_relations'
        relations[:organizations] = 'source_organizations'
        relations[:songs] = 'song_sources'
        relations[:seasons] = 'source_seasons'
        relations[:tags] = 'taglists'
      elsif record_class == Song
        relations[:artists] = 'artist_songs'
        relations[:sources] = 'song_sources'
        relations[:related_songs] = 'related_song_relations'
        relations[:tags] = 'taglists'
      elsif record_class == Season
        relations[:sources] = 'source_seasons'
      elsif record_class == Event
        relations[:albums] = 'album_events'
      elsif record_class == Tag
        relations[:albums] = 'taglists'
        relations[:artists] = 'taglists'
        relations[:organizations] = 'taglists'
        relations[:sources] = 'taglists'
        relations[:songs] = 'taglists'
      end
      relations
    end

end