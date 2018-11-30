class Organization < ApplicationRecord

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

  #Categories
    Activity = ["Active", "Hiatus", "Dissolved"]
    Categories = ["Label","Doujin Group","Game Company"]
    SelfRelationships = [["is a parent company of", "Subsidaries", 'Parent Company', "Parent"],
    ['is a subsidary of', '-Parent'], #aka child
    ['was formerly known as', '-Formerly'],
    ['Changed its name to', 'Succeeded By', 'Formerly', 'Formerly'],
    ['was a collaboration of', '-Collab'],
    ['has a collab', 'Collborations', 'Is a Collaboration Of', 'Collab'],
    ['is partners with', 'Partners', 'Partners', 'Partner']]

  #Validation
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Organization::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Organization::Categories, allow_nil: true, allow_blank: true

  #Associations
    #Primary Associations
      has_many :album_organizations
      has_many :albums, through: :album_organizations, dependent: :destroy

      has_many :artist_organizations
      has_many :artists, through: :artist_organizations, dependent: :destroy

      has_many :source_organizations
      has_many :sources, through: :source_organizations, dependent: :destroy

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :with_activity, ->(activities) {where('activity IN (?)', activities)}

  #Gem Stuff
    #Pagination
    paginates_per 50

end
