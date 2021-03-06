class Log < ApplicationRecord

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
  def add_to_content(level, text, tags = '', print_to_log = false) #(DEBUG INFO WARN ERROR FATAL UNKNOWN)
    entry = "[#{level.upcase}]"
    entry += tags.split(',').map { |i| "[#{i}]"}.join unless tags.blank?
    entry += text
    self.update_attribute(:content, (self.reload.content || "") + entry + "\n")
    logger.send(level.downcase,text) if print_to_log
  end

  def previous_log
    Log.where(category: self.category).where("id < ?", self.id).last
  end

  def next_log
    Log.where(category: self.category).where("id > ?", self.id).first
  end

  #Class Methods
    def self.find_last(category)
        self.where(category: category).last
    end

    def self.find_or_create_by_length(category, length)
        log = find_last(category)
        if log.nil?
          log = Log.create(category: category)
          log.add_to_content('info','No previous log found!','Start')
        elsif log.content.nil? == false && log.content.length > length
          log.add_to_content('info',"[End Log] Content length limit reached at #{Time.now}",'End')
          log = Log.create(category: category)
          log.add_to_content('info','Content Length Reached on old log','Start')
        end
        return log
    end

end