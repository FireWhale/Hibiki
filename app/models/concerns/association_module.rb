module AssociationModule
  extend ActiveSupport::Concern

  def manage_primary_relation(model, join_model)
    #Update Relations
    unless self.try("update_#{join_model.model_name.plural}").blank?
      self.send("update_#{join_model.model_name.plural}").each do |k,v|
        record = self.send(join_model.model_name.plural).find_by_id(k)
        record.update_attributes(v) unless record.nil?
      end
    end

    #Destroy Relations
    unless self.send("remove_#{join_model.model_name.plural}").blank?
      self.send("remove_#{join_model.model_name.plural}").each do |id|
        record = self.send("#{join_model.model_name.plural}").find_by_id(id)
        record.destroy unless record.nil?
      end
    end

    #Create New Relations
    new_relations = HashWithIndifferentAccess.new(self.send("new_#{model.model_name.plural}"))
    unless new_relations.blank?
      if new_relations.key?(:id)
        new_relations[:id].zip(new_relations.except(:id).values.transpose).each do |info|
          record = model.find_by_id(info[0])
          attributes = {model.model_name.param_key.to_sym => record}
          attributes = attributes.merge([new_relations.except(:id).keys,info[1]].transpose.to_h) unless info[1].nil?
          self.send("#{join_model.model_name.plural}").create(attributes) unless record.nil?
        end
      end
    end

    #Create New Relations By Name!
    new_relations_by_name = HashWithIndifferentAccess.new(self.try("new_#{model.model_name.plural}_by_name"))
    unless new_relations_by_name.blank?
      if new_relations_by_name.key?(:internal_name)
        new_relations_by_name[:internal_name].zip(new_relations_by_name.except(:internal_name).values.transpose).each do |info|
          unless info[0].empty?
            record = model.find_by_internal_name(info[0])
            if model == Event
              record = model.create(:internal_name => info[0]) if record.nil?
            else
              record = model.create(:internal_name => info[0], status: "Unreleased") if record.nil?
            end
            attributes = {model.model_name.param_key.to_sym => record}
            attributes = attributes.merge([new_relations_by_name.except(:internal_name).keys,info[1]].transpose.to_h) unless info[1].nil?
            self.send("#{join_model.model_name.plural}").create(attributes) unless record.nil?
          end
        end
      end
    end
  end

  def manage_artist_relation
    #Update relations
    update_artist_relations = HashWithIndifferentAccess.new(self.send("update_artist_#{self.class.model_name.plural}"))
    unless update_artist_relations.blank?
      update_artist_relations.each do |k,v|
        record = self.send("artist_#{self.class.model_name.plural}").find_by_id(k)
        unless record.nil?
          bitmask = Artist.get_bitmask(v[:category])
          bitmask == 0 ? record.destroy : record.update_attributes(:category => bitmask)
        end
      end
    end

    #Add artists
    add_artists = HashWithIndifferentAccess.new(self.new_artists)
    unless add_artists.blank?
      if add_artists.key?(:id) && add_artists[:category].blank? == false
        categories = add_artists[:category]
        categories.pop if categories.last == "New Artist" #Remove the last "New Artist" from the array
        categories = categories.split { |i| i == "New Artist"}
        add_artists[:id].zip(categories).each do |info|
          unless info[0].blank? || info[0].blank?
            bitmask = Artist.get_bitmask(info[1])
            artist = Artist.find_by_id(info[0])
            self.send("artist_#{self.class.model_name.plural}").create(artist: artist, category: bitmask) unless artist.nil?
          end
        end
      end
      if add_artists.key?(:internal_name) && add_artists[:category_by_name].blank? == false
        replace_artists = Album::Artistreplace
        ignored_artists = Album::IgnoredArtistNames
        categories = add_artists[:category_by_name]
        categories.pop if categories.last == "New Artist" #Remove the last "New Artist" from the array
        categories = categories.split { |i| i == "New Artist"}
        add_artists[:internal_name].zip(categories).each do |info|
          unless info[0].blank? || info[1].blank? || ignored_artists.include?(info[0])
            bitmask = Artist.get_bitmask(info[1])
            if replace_artists.map {|n| n[0]}.include?(info[0]) #if found in replace artists, replace the artist
              artist = Artist.find_by_id(replace_artists[replace_artists.index {|n| n[0] == info[0] }][1])
            else
              artist = Artist.find_by_internal_name(info[0])
              artist = Artist.create(internal_name: info[0], status: "Unreleased") if artist.nil?
            end
            self.send("artist_#{self.class.model_name.plural}").create(artist: artist, category: bitmask)
          end
        end
      end
    end
  end

end
