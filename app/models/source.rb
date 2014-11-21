class Source < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :altname, :namehash, #Names!
                    :status, :db_status, :category, :activity, #Database Stuff!
                    :reference, :info, :private_info, :synopsis, :plot_summary, #Text Info!
                    :release_date, :end_date, #Dates!
                    :popularity #Not yet implemented

    attr_accessor   :album_count
    
    serialize :reference
    serialize :namehash
  
  
  #Modules
    include FormattingModule
    include WatchlistModule

  #Callbacks/Hooks
    
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
    ['\'s franchise includes', 'Franchise Includes', 'Part of Franchie', 'Franchise'],
    ['is part of the franchise', '-Franchise'],
    ['is a side story of', '-Parent Story'], #aka Side Story
    ['is in the same series as', 'Same Series', 'Same Series', 'Same Series'], #order doesn't matter
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version'],
    ['is in an alternate setting of', 'Alternate Setting', 'Alternate Setting', 'Alternate Setting']] #order doesn't matter
  
    FullUpdateFields = {reference: true, seasons: true,
                        relations_by_id: {organization: [:new_organization_ids, :new_organization_categories, :update_source_organizations, :remove_source_organizations, SourceOrganization, "source_organizations"]},
                        self_relations: [:new_related_source_ids, :new_related_source_categories, :update_related_sources, :remove_related_sources],
                        images: ["id", "sourceimages/", "Primary"], 
                        dates: ["release_date", "end_date"]}
                        
    FormFields = [["text", :name, "Name:"], ["text", :altname, "Alternate Name:"], 
                  ["select", :status, "Status:", Album::Status],["select", :db_status, "Database Status:", Artist::DatabaseStatus],
                  ["select", :category, "Product/Franchise:", Source::Categories], ["select", :activity, "Activity:", Source::Activity], 
                  ["references"], ["date", :release_date, "Release Date:"], ["date", :end_date, "End Date:"], ["images"], ["tags"],
                  ["text-area", :info, 4 ], ["text-area", :synopsis, 2],
                  ["split"],
                  ["self-relations"], ["related_model", "organization", "source_organizations", "source[remove_source_organizations][]", "source[new_organization_ids]",
                   "source[update_source_organizations]", SourceOrganization::Categories, "source[new_organization_categories]"], ["namehash"], ["text-area", :private_info, 10]]
                  
  #Validation
    validates :name, presence: true , uniqueness: {scope: [:reference]}
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Source::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Source::Categories, allow_nil: true, allow_blank: true
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}
    validates :end_date, presence: true, unless: -> {self.end_date_bitmask.nil?}
    validates :end_date_bitmask, presence: true, unless: -> {self.end_date.nil?}
  
  #Associations
    #Primary Aassociations
      has_many :related_source_relations1, class_name: "RelatedSources", foreign_key: 'source1_id', :dependent => :destroy
      has_many :related_source_relations2, class_name: "RelatedSources", foreign_key: 'source2_id', :dependent => :destroy
      has_many :related_sources1, :through => :related_source_relations1, :source => :source2
      has_many :related_sources2, :through => :related_source_relations2, :source => :source1
      
      def related_source_relations
        related_source_relations1 + related_source_relations2
      end
      
      def related_sources
        related_sources1 + related_sources2
      end
    
      has_many :album_sources, dependent: :destroy
      has_many :albums, through: :album_sources
      
      has_many :source_organizations, dependent: :destroy
      has_many :organizations, through: :source_organizations
      
      has_many :song_sources, dependent: :destroy
      has_many :songs, through: :song_sources
        
    #Secondary Associations
      has_many :taglists, dependent: :destroy, as: :subject
      has_many :tags, through: :taglists
      
      has_many :imagelists, dependent: :destroy, as: :model
      has_many :images, through: :imagelists
      has_many :primary_images, through: :imagelists, source: :image, conditions: "images.primary_flag = 'Primary'" 
    
      has_many :postlists, dependent: :destroy, as: :model
      has_many :posts, through: :postlists
    
      has_many :source_seasons, dependent: :destroy
      has_many :seasons, through: :source_seasons
    
    #User Associations
      has_many :watchlists, as: :watched, dependent: :destroy
      has_many :watchers, through: :watchlists, source: :user
      
  #Scopes
    scope :released, -> { where(status: "Released")}
      
  #Gem Stuff
    #Pagination    
      paginates_per 50
      
    #Sunspot Searching
      searchable do
        text :name, :altname, :namehash, :boost => 5
        text :reference
      end
   
end
