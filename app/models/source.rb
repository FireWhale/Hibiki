class Source < ApplicationRecord

  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
    include DateModule
    include NeoNodeModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include LogModule
      include TagModule
      include ReferenceModule
      include WatchlistModule

  #Attributes
    serialize :namehash

  #Constants
    Activity = ["Complete", "Ongoing", "Not Yet Aired"]
    Categories = ["Franchise","Product"]
    SelfRelationships = [['is a prequel of', 'Sequel', 'Prequel', 'Prequel'],
    ['is a sequel of', '-Prequel'], #aka sequel
    ['is adapted as', 'Adpated As', 'An Adaption Of', 'Adaptation'],
    ['is an adaptation of', '-Adaptation'],
    ['has the same setting as', 'Same Setting', 'Same Setting', 'Same Setting'], #order doesn't matter
    ['shares characters with', 'Shares Characters', 'Shares Characters', 'Shares Characters'], #order doesn't matter
    ['is the parent story of', 'Side Story', 'Parent Story', 'Parent Story'],
    ['has the fandisc', '-Fan Disc'],
    ['is a fandisc of', 'Original Story', 'Fan Disc', 'Fan Disc'],
    ['\'s franchise includes', 'Franchise Includes', 'Part of Franchise', 'Franchise'],
    ['is part of the franchise', '-Franchise'],
    ['is a side story of', '-Parent Story'], #aka Side Story
    ['is in the same series as', 'Same Series', 'Same Series', 'Same Series'], #order doesn't matter
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version'],
    ['is in an alternate setting of', 'Alternate Setting', 'Alternate Setting', 'Alternate Setting']] #order doesn't matter

  #Validation
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Source::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Source::Categories, allow_nil: true, allow_blank: true

  #Associations
    #Primary Aassociations
      has_many :album_sources, dependent: :destroy
      has_many :albums, through: :album_sources

      has_many :source_organizations, dependent: :destroy
      has_many :organizations, through: :source_organizations

      has_many :song_sources, dependent: :destroy
      has_many :songs, through: :song_sources

    #Secondary Associations
      has_many :source_seasons, dependent: :destroy
      has_many :seasons, through: :source_seasons

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :with_activity, ->(activities) {where('activity IN (?)', activities)}
    scope :in_date_range, ->(start_date, end_date) {where("sources.release_date >= ? and sources.release_date <= ? ", start_date, end_date)}

  #Gem Stuff
    #Pagination
    paginates_per 50
end