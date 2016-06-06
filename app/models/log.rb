class Log < ActiveRecord::Base

  #Callbacks/Hooks

  #Constants
    Categories = ["Scrape","Rescrape","Watch Scrape"]

  #Validation
    validates :category, inclusion: Log::Categories

  #Associations
    has_many :loglists, dependent: :destroy
    has_many :albums, through: :loglists, source: :model, source_type: "Album"
    has_many :artists, through: :loglists, source: :model, source_type: "Artist"
    has_many :organizations, through: :loglists, source: :model, source_type: "Organization"
    has_many :songs, through: :loglists, source: :model, source_type: "Song"
    has_many :sources, through: :loglists, source: :model, source_type: "Source"
    has_many :events, through: :loglists, source: :model, source_type: "Event"

    def models
      loglists.map(&:model)
    end

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}

  #Instance Methods
    def add_to_content(text)
      self.update_attribute(:content, (self.reload.content || "") + text)
    end
end
