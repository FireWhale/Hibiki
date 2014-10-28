class User < ActiveRecord::Base
  attr_accessible :birthdate, :email, :explicit, :location, :name, :password, :password_confirmation, :privacy, :profile, :security, :sex, :stylesheet, :usernames, :display_bitmask, :language_settings, :artist_language_settings, :birthdate_bitmask
  
  #Validation
    validates :name, :presence => true   
    validates :email, :uniqueness => { :case_sensitive => false }, :allow_blank => true

  #Authetication and Security
    Security = %w[Admin SpecialUser User Unconfirmed]  
    
    acts_as_authentic do |c|
      c.login_field = :name
      c.perishable_token_valid_for = 3.hour
    end
  
  #Display Settings constants
    Languages = "English,Japanese,Romaji,Korean,RomanizedKorean,Chinese,Pinyin,Chinese (Traditional)"
    DefaultLanguages = "English,Romaji,RomanizedKorean,Pinyin,Japanese,Korean,Chinese,Chinese (Traditional)"
    DisplaySettings = %w[DisplayLEs DisplayNWS DisplayIgnored AlbumArtOutline Bolding EditMode] 
    PrivacySettings = %w[ShowWatchlist ShowCollection]
    DefaultDisplaySettings = %w[DisplayLEs DisplayIgnored]
    
  #Relationships
    has_many :watchlists, dependent: :destroy
    has_many :watched_sources, :through => :watchlists, :source => :watched, :source_type => 'Source'
    has_many :watched_organizations, :through => :watchlists, :source => :watched, :source_type => 'Organization'
    has_many :watched_artists, :through => :watchlists, :source => :watched, :source_type => 'Artist'
    
    def watching
      watched_sources + watched_organizations + watched_artists
    end
    
    has_many :collections
    has_many :albums, :through => :collections, dependent: :destroy
    
    has_many :ratings
    has_many :songs, :through => :ratings, dependent: :destroy
    
    has_many :imagelists, :as => :model
    has_many :images, :through => :imagelists, dependent: :destroy  
    
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
  
end
