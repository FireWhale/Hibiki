module LanguageModule

 def read_name(user = nil)
    #gets the "name" of a record, drawing from 3 places and ignoring one:
    #Ignores synonyms. those are for our search engine. 
    
    #Initialize an array
    name_array = []
    
    #figure out which setting to use
    if self.class == Artist || self.class == Organization
      language_settings = "artist_language_settings"
    else
      language_settings = "language_settings"
    end
    
    #We use i18n locales for nil users and users who have nil/empty language settings 
    if user.nil? || user.send(language_settings).blank?
      if I18n.locale == :en
        priority_languages = 'english,romaji'  
      elsif I18n.locale == :ja
        priority_languages = 'japanese'
      end
    else
      priority_languages = user.send(language_settings)
    end
    
    #Add name_translations to array
    name_translations = self.name_translations
    priority_languages.split(",").each do |lang|
      name_array << name_translations.delete("hibiki_#{lang[0..1]}")
    end
    name_translations.each { |k,v| name_array << v } #add remaining name_translations
    
    #Add namehash to array
    self.namehash.each {|k,v| name_array << v} unless self.namehash.nil?
    
    #Add internal_name to array
    name_array << self.internal_name
    
    #Get rid of nil values in name_translations
    name_array.reject! { |a| a.blank? }
  end
  
  def read_info
    
  end
  
  def read_lyrics
    
  end  
end
