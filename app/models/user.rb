class User < ApplicationRecord
  #Modules
    #Association Modules
      include ImageModule
      include JsonModule
      include ReferenceModule
      include DateModule

  #Attributes
    attr_accessor :display_form_settings
    attr_accessor :privacy_form_settings
    attr_accessor :language_form_settings
    attr_accessor :artist_language_form_settings

  #Callbacks/Hooks
    before_save :manage_profile_settings

  #Constants
    EditProfileFields = [{type: "markup", tag_name: "div id='small-view'"},
                         {type: "profile_settings"},{type: "markup", tag_name: "/div"}]

  #Validation
    validates :name, presence: true, length: { minimum: 3, maximum: 20}
    validates :email, uniqueness: { :case_sensitive => false },presence: true
    validates :crypted_password, presence: true
    validates :password_salt, presence: true
    validates_format_of :password, without: ->(user) {/#{user.name}/}, message: "must not contain username", unless: -> {self.password.nil?}
    validates_format_of :password, with: /(?=.*[A-Za-z])(?=.*[0-9])[A-Za-z0-9]+/, message: "must contain at least one letter and one number", unless: -> {self.password.nil?}
    validates :status, inclusion: ["Deactivated", ""], unless: -> {self.status.nil?}

  #Authetication and Security
    acts_as_authentic do |c|
      c.login_field = :name
      c.perishable_token_valid_for = 3.hour
      c.merge_validates_length_of_password_field_options :minimum => 8
      c.merge_validates_length_of_password_confirmation_field_options
      if RbConfig::CONFIG['host_os'] == "mingw32" #Patch for windows OS
        c.crypto_provider = Authlogic::CryptoProviders::Sha512
      else
        c.crypto_provider = Authlogic::CryptoProviders::SCrypt
      end

    end

  #Display Settings constants - add to end
    Languages = ["english","romaji","japanese","chinese","korean"]
    DisplaySettings = ["Display Limited Editions", "Display NWS", "Display Ignored", "Outline Album Art", "Bold AOS", "Edit Mode", "Display Reprints"]
    PrivacySettings = ["Show Watchlist", "Show Collection", "Show Profile"]

    DefaultLanguages = []
    DefaultDisplaySettings = ["Display Limited Editions", "Display Ignored", "Display Reprints"]
    DefaultPrivacySettings = []

  #Associations
    has_many :user_roles, class_name: 'Users::UserRole', dependent: :destroy, autosave: true
    has_many :roles, through: :user_roles, class_name: 'Users::Role'

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
    Notifier.password_reset_instructions(self).deliver_now
  end

  #Gem Stuff
    #Pagination
    paginates_per 50

  #Bitmask Methods
    def display_settings
      displayarray = User::DisplaySettings
      displayarray.reject { |r| ((self.display_bitmask || 0 ) & 2**displayarray.index(r)).zero?}
    end

    def abilities
      self.status == "Deactivated" ? [] : roles.pluck(:name) + ['Any']
    end

    def privacy_settings
      privacy_array = User::PrivacySettings
      privacy_array.reject { |r| ((self.privacy.to_i || 0 ) & 2**privacy_array.index(r)).zero? }
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
      language_settings.select {|language| User::Languages.include?(language)}.uniq.join(",")
    end

    def album_filter #Used in an album scope 'filter_by_user_settings' to filter things out of view
      #["Limited Edition", "Reprint", "Ignored"] will be passed in to filter it out
      array = []
      array << "Limited Edition" unless self.display_settings.include?("Display Limited Editions") #1
      array << "Reprint" unless self.display_settings.include?("Display Reprints") #64
      array << "Ignored" unless self.display_settings.include?("Display Ignored") #4
      array
    end

  private
    def manage_profile_settings
      self.display_bitmask = User.get_display_bitmask(self.display_form_settings) unless self.display_form_settings.nil?
      self.privacy = User.get_privacy_bitmask(self.privacy_form_settings) unless self.privacy_form_settings.nil?
      self.language_settings = User.get_language_settings(self.language_form_settings) unless self.language_form_settings.nil?
      self.artist_language_settings = User.get_language_settings(self.artist_language_form_settings) unless self.artist_language_form_settings.nil?
    end

end
