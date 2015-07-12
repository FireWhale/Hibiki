class Organization < ActiveRecord::Base
  #Attributes
    attr_accessible :internal_name, :synonyms, :namehash, #Names!
                    :status, :db_status, :category, :activity, #Database Stuff!
                    :info, :private_info, :synopsis, #Text Info!
                    :established, #Dates!
                    :popularity #Not yet implemented
     
    serialize :namehash
      
  #Modules
    include FullUpdateModule
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

  #Callbacks/Hooks
    before_validation :convert_names
      
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
    
    FullUpdateFields = {reference: true,
                        relations_by_id: {artist: [:new_artist_ids, :new_artist_categories, :update_artist_organizations, :remove_artist_organizations, ArtistOrganization, "artist_organizations"]},
                        self_relations: [:new_related_organization_ids, :new_related_organization_categories, :update_related_organizations, :remove_related_organizations],
                        images: ["id", "orgimages/","Primary"],
                        languages: [:name, :info],
                        dates: ["established"]}

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

  def convert_names
    @name_hash = self.namehash
    unless @name_hash.blank?
      #Convert the ones we want to convert
      @name_hash.each do |k,v|
        if [:English, :Romaji, :Japanese].include?(k)
          self.write_attribute(:name, v, locale: "hibiki_#{k.to_s.downcase[0..1]}".to_sym) unless v.nil?
          @name_hash.except!(k) #Remove the key from the hash
        end
      end
      self.namehash = (@name_hash.empty? ? nil : @name_hash)
    end
    #Remove duplicates from synonym
    @name_translations = self.name_translations.values
    self.synonyms = nil if @name_translations.include?(self.synonyms)
  end  

end
