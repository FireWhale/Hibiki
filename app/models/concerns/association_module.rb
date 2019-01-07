module AssociationModule
  extend ActiveSupport::Concern

  def manage_primary_relation(model, join_model)
    #TODO delete this stuff

    #Create New Relations By Name! For scraping.
    new_relations_by_name = ActiveSupport::HashWithIndifferentAccess.new(self.try("new_#{model.model_name.plural}_by_name"))
    unless new_relations_by_name.blank?
      if new_relations_by_name.key?(:internal_name)

        if new_relations_by_name[:url_by_name].nil?
          urls = Array.new(new_relations_by_name[:internal_name].length)
        else
          urls =  new_relations_by_name[:url_by_name]
        end

        new_relations_by_name[:internal_name].zip(urls,new_relations_by_name.except(:internal_name,:url_by_name).values.transpose).each do |info|
          unless info[0].empty?
            record = model.find_by_internal_name(info[0])
            if model == Event
              record = model.create(:internal_name => info[0]) if record.nil?
            else
              record = model.create(:internal_name => info[0], status: "Unreleased") if record.nil?
            end
            if record.nil? == false && record.references("VGMdb").nil? && info[1].blank? == false #Handle urls
              record.new_references = info[1]
              record.save
            end
            attributes = {model.model_name.param_key.to_sym => record}
            attributes = attributes.merge([new_relations_by_name.except(:internal_name,:url_by_name).keys,info[2]].transpose.to_h) unless info[2].nil?
            self.send("#{join_model.model_name.plural}").create(attributes) unless record.nil?
          end
        end
      end
    end
  end

  def manage_artist_relation
    #Add artists
    add_artists = ActiveSupport::HashWithIndifferentAccess.new(self.new_artists)
    unless add_artists.blank?
      if add_artists.key?(:internal_name) && add_artists[:category_by_name].blank? == false #add by name and category
        replace_artists = Album::Artistreplace
        ignored_artists = Album::IgnoredArtistNames
        categories = add_artists[:category_by_name]
        categories.pop if categories.last == "New Artist" #Remove the last "New Artist" from the array
        categories = categories.split { |i| i == "New Artist"}

        if add_artists[:display_language_by_name].nil?
          name_languages = add_artists[:internal_name].map { |w| :hibiki_en} #auto add english
        else
          name_languages = add_artists[:display_language_by_name]
        end

        if add_artists[:url_by_name].nil?
          name_urls = Array.new(add_artists[:internal_name].length)
        else
          name_urls = add_artists[:url_by_name]
        end

        add_artists[:internal_name].zip(categories,name_languages,name_urls).each do |info|
          unless info[0].blank? || info[1].blank? || ignored_artists.include?(info[0])
            bitmask = Artist.get_bitmask(info[1])
            if replace_artists.map {|n| n[0]}.include?(info[0]) #if found in replace artists, replace the artist
              artist = Artist.find_by_id(replace_artists[replace_artists.index {|n| n[0] == info[0] }][1])
            else
              artist = Artist.find_by_internal_name(info[0])
              artist = Artist.create(internal_name: info[0], status: "Unreleased") if artist.nil?
              if artist.references("VGMdb").nil? && info[3].blank? == false #Adds urls if urls are passed in as well (from vgmdb scrap)
                artist.new_references = info[3]
                artist.save
              end
            end
            self.send("artist_#{self.class.model_name.plural}").create(artist: artist, category: bitmask, new_display_name_langs: [info[0]], new_display_name_lang_categories: [info[2]])
          end
        end
      end
    end
  end

end
