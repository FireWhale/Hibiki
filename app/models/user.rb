class User < ActiveRecord::Base
  attr_accessible :birth_date, :email, :explicit, :location, :name, 
                  :password, :password_confirmation, :privacy, :profile, 
                  :sex, :stylesheet, :usernames, :display_bitmask, 
                  :language_settings, :artist_language_settings

  #Modules
  
    #Association Modules
      include ImageModule
  
  #Validation
    validates :name, presence: true, length: { minimum: 3, maximum: 20}
    validates :email, uniqueness: { :case_sensitive => false }, allow_blank: true
    validates :crypted_password, presence: true
    validates :password_salt, presence: true
    validates_format_of :password, without: ->(user) {/#{user.name}/}, message: "must not contain username"
    validates_format_of :password, with: /(?=.*[A-Za-z])(?=.*[0-9])[A-Za-z0-9]+/, message: "must contain at least one letter and one number"
    validates :security, presence: true, inclusion: Array(0..(2**Ability::Abilities.count - 1)).map(&:to_s)
    validates :birth_date, presence: true, unless: -> {self.birth_date_bitmask.nil?}
    validates :birth_date_bitmask, presence: true, unless: -> {self.birth_date.nil?}

  #Authetication and Security    
    acts_as_authentic do |c|
      c.login_field = :name
      c.perishable_token_valid_for = 3.hour
      c.merge_validates_length_of_password_field_options :minimum => 8
      c.merge_validates_length_of_password_confirmation_field_options :allow_blank => true
      c.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
      c.crypto_provider = Authlogic::CryptoProviders::SCrypt
    end
  
  #Display Settings constants - add to end
    Languages = ["english","japanese","romaji","chinese","korean"]
    DefaultLanguages = "English,Romaji,RomanizedKorean,Pinyin,Japanese,Korean,Chinese,Chinese (Traditional)"
    DisplaySettings = %w[DisplayLEs DisplayNWS DisplayIgnored OutlineAlbumArt BoldAOS BoldForEditing DisplayReprints] 
    PrivacySettings = %w[ShowWatchlist ShowCollection]
    DefaultDisplaySettings = %w[DisplayLEs DisplayIgnored]
    
  #Associations
    has_many :watchlists, dependent: :destroy
    has_many :artists, through: :watchlists, source: :watched, source_type: 'Artist'
    has_many :organizations, through: :watchlists, source: :watched, source_type: 'Organization'
    has_many :sources, through: :watchlists, source: :watched, source_type: 'Source'
    
    has_many :collections, dependent: :destroy
    has_many :albums, through: :collections, source: :collected, source_type: 'Album'
    has_many :songs, through: :collections, source: :collected, source_type: 'Song'
    
    def watching
      sources + organizations + artists
    end
    
    def collecting
      albums + songs
    end
      
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
  end
  
  #Bitmask Methods    
    def display_settings
      displayarray = User::DisplaySettings    
      displayarray.reject { |r| ((self.display_bitmask || 0 ) & 2**displayarray.index(r)).zero?}    
    end
    
    def abilities
      abilities = Ability::Abilities
      abilities.reject { |r| ((self.security.to_i || 0 ) & 2**abilities.index(r)).zero? } + ['Any']
    end
    
    def self.get_security_bitmask(abilities)
      abilities = [abilities] if abilities.class != Array
      (abilities & Ability::Abilities).map { |r| 2**(Ability::Abilities).index(r) }.sum
    end
    
    def self.get_display_bitmask(display_settings)
      display_settings = [display_settings] if display_settings.class != Array
      (display_settings & User::DisplaySettings).map { |r| 2**(User::DisplaySettings).index(r) }.sum
    end
    
    def self.get_privacy_bitmask(privacy_settings)
      privacy_settings = [privacy_settings] if privacy_settings.class != Array
      (privacy_settings & User::PrivacySettings).map { |r| 2**(User::PrivacySettings).index(r) }.sum      
    end
    
    def self.get_language_settings(language_settings)
      language_settings.select {|language| User::Languages.include?(language)}.join(",")
    end
    
    def album_filter #Used in an album scope 'filter_by_user_settings' to filter things out of view
      #["Limited Edition", "Reprint", "Ignored"] will be passed in to filter it out
      array = []
      array << "Limited Edition" unless self.display_settings.include?("DisplayLEs") #1
      array << "Reprint" unless self.display_settings.include?("DisplayReprints") #64
      array << "Ignored" unless self.display_settings.include?("DisplayIgnored") #4
      array
    end
  
  #Update Method
    def update_security(values)
      abilities = values.delete :abilities
      self.update_attribute(:security, User.get_security_bitmask(abilities).to_s) unless abilities.nil?
    end
    
    def update_profile(values)
      display_settings = values.delete :display_settings
      self.update_attribute(:display_bitmask, User.get_display_bitmask(display_settings)) unless display_settings.nil?
      privacy_settings = values.delete :privacy_settings
      self.update_attribute(:privacy, User.get_privacy_bitmask(privacy_settings).to_s) unless privacy_settings.nil?
      language_settings = values.delete :language_settings
      self.update_attribute(:language_settings, User.get_language_settings(language_settings).to_s) unless language_settings.nil?
      artist_language_settings = values.delete :artist_language_settings
      self.update_attribute(:artist_language_settings, User.get_language_settings(artist_language_settings).to_s) unless artist_language_settings.nil?
    end
    
    
end
