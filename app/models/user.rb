class User < ActiveRecord::Base
  attr_accessible :birth_date, :email, :explicit, :location, :name, 
                  :password, :password_confirmation, :privacy, :profile, 
                  :sex, :stylesheet, :usernames, :display_bitmask, 
                  :language_settings, :artist_language_settings

  #Modules
    include FormattingModule
  
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
  
  #Display Settings constants
    Languages = "English,Japanese,Romaji,Korean,Romanized Korean,Chinese,Pinyin,Chinese (Traditional)"
    DefaultLanguages = "English,Romaji,RomanizedKorean,Pinyin,Japanese,Korean,Chinese,Chinese (Traditional)"
    DisplaySettings = %w[DisplayLEs DisplayNWS DisplayIgnored AlbumArtOutline Bolding EditMode] 
    PrivacySettings = %w[ShowWatchlist ShowCollection]
    DefaultDisplaySettings = %w[DisplayLEs DisplayIgnored]
    
  #Associations
    has_many :watchlists, dependent: :destroy
    has_many :watched_sources, :through => :watchlists, :source => :watched, :source_type => 'Source'
    has_many :watched_organizations, :through => :watchlists, :source => :watched, :source_type => 'Organization'
    has_many :watched_artists, :through => :watchlists, :source => :watched, :source_type => 'Artist'
    
    def watching
      watched_sources + watched_organizations + watched_artists
    end
    
    has_many :collections, dependent: :destroy
    has_many :albums, through: :collections
    
    has_many :ratings, dependent: :destroy
    has_many :songs, through: :ratings
    
    has_many :imagelists,  dependent: :destroy, as: :model
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag = 'Primary'" }, through: :imagelists, source: :image
    
    has_many :issue_users
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
  end
  
  #Bitmask Methods
    def tracklist_settings
      settings = Album::TracklistOptions.map {|k,v| k.to_s}
      settings.reject { |r| ((self.tracklist_export_bitmask || 0 ) & 2**settings.index(r)).zero?}    
    end
    
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
  
  
  #Update Method
    def update_security(values)
      abilities = values.delete :abilities
      self.security = User.get_security_bitmask(abilities).to_s
      self.save
    end
end
