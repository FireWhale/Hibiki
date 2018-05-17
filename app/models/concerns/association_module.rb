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
    new_relations = ActiveSupport::HashWithIndifferentAccess.new(self.send("new_#{model.model_name.plural}"))
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
    new_relations_by_name = ActiveSupport::HashWithIndifferentAccess.new(self.try("new_#{model.model_name.plural}_by_name"))
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
    update_artist_relations = ActiveSupport::HashWithIndifferentAccess.new(self.send("update_artist_#{self.class.model_name.plural}"))
    unless update_artist_relations.blank?
      update_artist_relations.each do |k,v|
        record = self.send("artist_#{self.class.model_name.plural}").find_by_id(k)
        unless record.nil?
          bitmask = Artist.get_bitmask(v[:category])
          bitmask == 0 ? record.destroy : record.update_attributes(:category => bitmask, new_display_name_langs: v[:display_name].try(:[],"names"), new_display_name_lang_categories: v[:display_name].try(:[],"languages"))
        end
      end
    end

    #Add artists
    add_artists = ActiveSupport::HashWithIndifferentAccess.new(self.new_artists)
    unless add_artists.blank?
      if add_artists.key?(:id) && add_artists[:category].blank? == false
        categories = add_artists[:category]
        display_names = add_artists[:display_name].try(:[],"names")
        display_name_languages = add_artists[:display_name].try(:[],"languages")

        categories.pop if categories.last == "New Artist" #Remove the last "New Artist" from the array
        categories = categories.split { |i| i == "New Artist"}

        if display_names.nil?
          display_names = Array.new(add_artists[:id].length)
        else
          display_names.pop if display_names.last == "New Artist"
          display_names = display_names.split { |i| i == "New Artist"}
        end

        if display_name_languages.nil?
          display_name_languages = Array.new(add_artists[:id].length)
        else
          display_name_languages.pop if display_name_languages.last == "New Artist"
          display_name_languages = display_name_languages.split { |i| i == "New Artist"}
        end


        add_artists[:id].zip(categories,display_names, display_name_languages).each do |info|
          unless info[0].blank? || info[0].blank?
            bitmask = Artist.get_bitmask(info[1])
            artist = Artist.find_by_id(info[0])
            self.send("artist_#{self.class.model_name.plural}").create(artist: artist, category: bitmask, new_display_name_langs: info[2], new_display_name_lang_categories: info[3]) unless artist.nil?
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
