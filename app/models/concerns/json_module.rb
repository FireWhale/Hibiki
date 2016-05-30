module JsonModule
  def as_json(options={})
    autocomplete_models = [Album, Artist, Organization, Song, Source]
    translated_models =  [Album, Artist, Organization, Song, Source, Event, Tag]
    banned_attributes = [:status, :db_status, :classification, :activity,
                        :popularity, :visibility, :lyrics,
                        :created_at, :updated_at, :release_date_bitmask, :model_bitmask,
                        :birth_date_bitmask, :debut_date_bitmask, :end_date_bitmask,
                        :established_bitmask, :blood_type, :gender, :birth_place,
                        :llimagelink, :namehash, :private_info, :rating]

    if options[:autocomplete].blank? == false && autocomplete_models.include?(self.class)
      hash = {:id => id,
              :label => read_name(options[:autocomplete_user])[0],
              :model => self.class.name}
      hash[:value] = read_name(options[:autocomplete_user])[0] if options[:autocomplete] == "search"
      hash[:value] = "#{id} - #{internal_name}" if options[:autocomplete] == "edit"
      return hash
    end

    self.class.include_root_in_json = true unless options[:root] == "skip" #defaults root to true unless root check is skipped.

    if options[:root] == false
      self.class.include_root_in_json = false
      output = self.as_json(options.merge({root: "skip"}))
      self.class.include_root_in_json = true
      return output
    end

    if self.class == User
      if options[:watchlists] == true
        return super(only: :id)
      elsif options[:collections] == true
        return super(only: :id)
      else
        return super(only: :id)
      end
    end

    if translated_models.include?(self.class)
      hash = super(:except => banned_attributes + [:name, :internal_name, :category, :synopsis, :info])
      hash_level = (self.include_root_in_json ? hash[self.class.name.downcase] : hash )
      hash_level["name"] = read_name(options[:user])[0]
      hash_level["name_translations"] = self.name_translations.delete_if {|k,v| v.blank?}

      hash_level["info"] = read_info(options[:user])[0]
      hash_level["info_translations"] = self.info_translations.delete_if {|k,v| v.blank?}

      if self.respond_to?(:lyrics)
        hash_level["lyrics"] = read_lyrics(options[:user])[0]
        hash_level["lyrics_translations"] = self.lyrics_translations.delete_if {|k,v| v.blank?}
      end

      if self.respond_to?(:abbreviation)
        hash_level["abbreviation"] = read_abbreviation(options[:user])[0]
        hash_level["abbreviation_translations"] = self.abbreviation_translations.delete_if {|k,v| v.blank?}
      end

      if self.class == Tag
        hash_level["classification"] = self.classification
      end

      if self.class == Album
        hash_level["song_info"] = {:total_songs => self.songs.count}
        disc_count = self.songs.map(&:disc_number).uniq.max
        hash_level["song_info"][:total_discs] = disc_count unless disc_count.nil?
      end

      hash_level.reject! {|k,v| v.blank? }

      return hash
    end

    if self.class == Issue
      banned_attributes = banned_attributes - [:status]
    end

    hash = super(:except => banned_attributes) #let issue have status
    hash_level = (self.include_root_in_json ? hash[self.class.name.downcase] : hash )
    hash_level.reject! {|k,v| v.blank? }
    return hash

    #super(:except => banned_attributes)
  end

end
