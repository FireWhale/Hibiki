module LanguageModule
  extend ActiveSupport::Concern

  Locales = [:hibiki_en, :hibiki_ja, :hibiki_ro, :hibiki_fr]

  #This module covers additional methods layered onto globalize to make it work with Hibiki
  #These methods are necessary because the default globalize methods don't work for the app.

  included do
    translates :name
    translates :info
    translates :lyrics if self.name == "Song"
    translates :abbreviation if self.name == "Event"

    attr_accessor :name_langs
    attr_accessor :new_name_langs
    attr_accessor :new_name_lang_categories

    attr_accessor :info_langs
    attr_accessor :new_info_langs
    attr_accessor :new_info_lang_categories

    if self.name == "Song"
      attr_accessor :lyrics_langs
      attr_accessor :new_lyrics_langs
      attr_accessor :new_lyrics_lang_categories
    end

    if self.name == "Event"
      attr_accessor :abbreviation_langs
      attr_accessor :new_abbreviation_langs
      attr_accessor :new_abbreviation_lang_categories
    end

    before_validation :convert_names unless self.name == "Event" || self.name == "Tag"
    before_validation :manage_locale_info #After convert_names since this is higher presidence
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

    #Get rid of blank values in name_translations
    name_array.reject! { |a| a.blank? }
    #return name_array
    return name_array
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

    def manage_locale_info
      self.translated_attribute_names.each do |field|
        #New
        new_locale_values = self.send("new_#{field}_langs")
        new_locale_categories = self.send("new_#{field}_lang_categories")
        unless new_locale_values.blank? || new_locale_categories.blank?
          new_locale_values.zip(new_locale_categories).each do |pair|
            if LanguageModule::Locales.include?(pair[1].to_sym)
              self.write_attribute(field, pair[0], locale: pair[1].to_sym)
            end
          end
        end
        #Update - Handle old values second since they take priority over values from new languages
        old_locales = self.send("#{field}_langs")
        unless old_locales.blank?
          old_locales.each do |locale, value|
            if LanguageModule::Locales.include?(locale.to_sym)
              self.write_attribute(field, value, locale: locale.to_sym)
            end
          end
        end
      end
    end

    def convert_names
      name_hash = HashWithIndifferentAccess.new(self.namehash)
      unless name_hash.blank?
        name_hash.delete_if { |k,v| v.blank? }
        #Compare entries in the namehash to remove duplicates for songs only.
        if self.class == Song
          unless name_hash[:English].blank? && name_hash[:Japanese].blank?
            if name_hash[:English] == name_hash[:Japanese]
              if name_hash[:Japanese].contains_japanese?
                name_hash[:English] = nil
              else
                name_hash[:Japanese] = nil
              end
            end
          end
        end
        #Convert the ones we want to convert
        name_hash.each do |k,v|
          if [:English, :Romaji, :Japanese, "English", "Japanese", "Romaji"].include?(k)
            self.write_attribute(:name, v, locale: "hibiki_#{k.to_s.downcase[0..1]}".to_sym) unless v.blank?
            name_hash.except!(k) #Remove the key from the hash
          end
        end
        self.namehash = (name_hash.empty? ? nil : name_hash)
      end
      #Remove duplicates from synonym
      all_name_translations = self.name_translations.values
      self.synonyms = nil if all_name_translations.include?(self.synonyms)
    end
end
