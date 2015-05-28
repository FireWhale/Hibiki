module LanguageModule
  extend ActiveSupport::Concern
  
  #This module covers additional methods layered onto globalize to make it work with Hibiki
  #These methods are necessary because the default globalize methods don't work for the app.

  included do
    translates :name
    translates :info
    translates :lyrics if self.name == "Song"
    translates :abbreviation if self.name == "Event"
  end
  
  
  def read_name(user = nil)
    #gets the "name" of a record, drawing from 3 places and ignoring one:
    #Ignores synonyms. those are for our search engine. 
    
    #Initialize an array
    name_array = []
    
    #figure out which setting to use
    priority_languages = get_languages(self,user)

    #Add name_translations to array
    name_translations = self.name_translations
    priority_languages.split(",").each do |lang|
      name_array << name_translations.delete("hibiki_#{lang[0..1]}")
    end
    name_translations.each { |k,v| name_array << v } #add remaining name_translations
    
    #Add namehash to array
    self.namehash.each {|k,v| name_array << v} unless self.respond_to?(:namehash) == false || self.namehash.nil?
    
    #Add internal_name to array
    name_array << self.internal_name
    
    #Get rid of nil values in name_translations
    name_array.reject! { |a| a.blank? }
    #return name_array
    name_array
  end
  
  def read_info(user = nil)
    #Gets info. only from info and untranslated info
    
    #Initialize the array
    info_array = []
    
    #figure out which setting to use
    priority_languages = get_languages(self,user)
    
    #Add info_translations to array
    info_translations = self.info_translations
    priority_languages.split(",").each do |lang|
      info_array << info_translations.delete("hibiki_#{lang[0..1]}")
    end
    info_translations.each { |k,v| info_array << v } #add remaining name_translations
    
    #add untranslated_info
    info_array << self.read_attribute(:info, translated: false)
    
    #Get rid of nil values in info_translations
    info_array.reject! { |a| a.blank? }
    
    #return info_array
    info_array
  end
  
  def read_lyrics(user = nil)
    #Gets lyrics. only from translated record lyrics
    
    #Initialize the array
    lyrics_array = []
    
    #figure out which setting to use
    priority_languages = get_languages(self,user)
    
    #Add info_translations to array
    lyrics_translations = self.lyrics_translations
    priority_languages.split(",").each do |lang|
      lyrics_array << lyrics_translations.delete("hibiki_#{lang[0..1]}")
    end
    lyrics_translations.each { |k,v| lyrics_array << v } #add remaining name_translations
    
    lyrics_array.reject! { |a| a.blank? }
    
    #return lyric array
    lyrics_array
  end
  
  def read_abbreviation(user = nil)
    abbreviation_array = []
    priority_languages = get_languages(self,user)
    
    abbreviation_translations = self.abbreviation_translations
    priority_languages.split(",").each do |lang|
      abbreviation_array << abbreviation_translations.delete("hibiki_#{lang[0..1]}")
    end
    abbreviation_translations.each { |k,v| abbreviation_array << v } #add remaining abbreviation_translations
    
    abbreviation_array.reject! { |a| a.blank? }
    
    abbreviation_array    
  end
  
  private 
  
  def get_languages(record,user)
    if record.class == Artist || record.class == Organization
      language_settings = "artist_language_settings"
    else
      language_settings = "language_settings"
    end
    #We use i18n locales for nil users and users who have nil/empty language settings 
    if user.nil? || user.send(language_settings).blank?
      if I18n.locale == :en #I'm assuming this is how locales work
        priority_languages = 'english,romaji'  
      elsif I18n.locale == :ja
        priority_languages = 'japanese'
      end
    else
      priority_languages = user.send(language_settings)
    end    
  end
end
