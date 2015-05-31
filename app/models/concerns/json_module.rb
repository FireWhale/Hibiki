module JsonModule  
  def as_json(options={})
    autocomplete_models = [Album, Artist, Organization, Song, Source]
    translated_models =  [Album, Artist, Organization, Song, Source, Event, Tag]
    banned_attributes = [:status, :db_status, :classification, :activity,
                        :popularity, :visibility, :reference, :lyrics,
                        :created_at, :updated_at, :release_date_bitmask, :model_bitmask,
                        :birth_date_bitmask, :debut_date_bitmask, :end_date_bitmask,
                        :established_bitmask,
                        :llimagelink, :namehash, :private_info]
        
    if self.class == User
      if options[:watchlists] == true
        
      elsif options[:collections] == true
        
      else
        super(only: :id)
      end
    elsif options[:autocomplete_search] == true && autocomplete_models.include?(self.class)
      {
        :id => id,
        :label => read_name(options[:autocomplete_user])[0],
        :value => read_name(options[:autocomplete_user])[0],
        :model => self.class.name
      }
    elsif options[:autocomplete_edit] == true && autocomplete_models.include?(self.class)
      {
        :id => id,
        :label => read_name(options[:autocomplete_user])[0],
        :value => "#{id} - #{internal_name}",
        :model => self.class.name
      }      
    elsif self.class == Issue
      super(:except => banned_attributes - [:status]) #let issue have status
    elsif translated_models.include?(self.class)
      hash = super(:except => banned_attributes + [:name, :category, :synopsis, :info])
      hash[self.class.name.downcase]["name"] = read_name(options[:user])[0]
      hash[self.class.name.downcase]["name_translations"] = self.name_translations.delete_if {|k,v| v.blank?}
      
      hash[self.class.name.downcase]["info"] = read_info(options[:user])[0]
      hash[self.class.name.downcase]["info_translations"] = self.info_translations.delete_if {|k,v| v.blank?}
      
      if self.class == Song
        hash[self.class.name.downcase]["lyrics"] = read_lyrics(options[:user])[0]
        hash[self.class.name.downcase]["lyrics_translations"] = self.lyrics_translations.delete_if {|k,v| v.blank?}
      end
      
      if self.class == Event
        hash[self.class.name.downcase]["abbreviation"] = read_abbreviation(options[:user])[0]
        hash[self.class.name.downcase]["abbreviation_translations"] = self.abbreviation_translations.delete_if {|k,v| v.blank?}
      end
      
      if self.class == Tag
        hash[self.class.name.downcase]["classification"] = self.classification
      end
      
      hash
    else
      #Remove extraneous and sensitive information
      super(:except => banned_attributes)
    end
  end  
end
