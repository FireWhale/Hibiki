class Organization < ActiveRecord::Base  
      
  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include TagModule
      include ReferenceModule
      include WatchlistModule
  
  #Attributes   
    serialize :namehash
    
    attr_accessor :new_artists
    attr_accessor :update_artist_organizations
    attr_accessor :remove_artist_organizations
    
  #Callbacks/Hooks
    after_save :manage_artists
  
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

    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "select", attribute: :activity, label: "Activity:", categories: Organization::Activity},
                  {type: "select", attribute: :category, label: "Categories:", categories: Organization::Categories},
                  {type: "references"},
                  {type: "date", attribute: :established, label: "Established:"}, 
                  {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "language_fields", attribute: :info},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :synopsis, rows: 2, label: "Synopsis:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Organization Relationships", sub_div_id: "Organizations"},
                  {type: "related_model", div_class: "well", title: "Artist Relationships", model: "artist", relation_model: "artist_organizations", categories: ArtistOrganization::Categories, sub_div_id: "Artists"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"}, 
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}]
    
  #Validation
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Organization::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Organization::Categories, allow_nil: true, allow_blank: true
    validates :established, presence: true, unless: -> {self.established_bitmask.nil?}
    validates :established_bitmask, presence: true, unless: -> {self.established.nil?}
  
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
  
  private
    def manage_artists
      self.manage_primary_relation(Artist,ArtistOrganization)
    end
end
