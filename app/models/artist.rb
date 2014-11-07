class Artist < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :altname, :namehash, #Names!
                    :status, :db_status, :category, :activity, #Database Stuff!
                    :reference, :info, :private_info, :synopsis, #Text Info!
                    :gender, :blood_type, :birth_place, #More Detailed Info!
                    :birth_date, :debut_date, #Dates!
                    :popularity #Not yet implemented
  
    serialize :reference
    serialize :namehash
  
  #Modules
    include FormattingModule
    include WatchlistModule

  #Cateogires
    Categories = ['Group','Person','Unit','Synthesized']
    Activity = ['Retired','Active','Hiatus']
    DatabaseStatus = ['Complete','Up to Date','Ignored','Out of Scope','Partial','Hidden']
      #Applies to Artists, Sources, Organizations
        #Complete - Artist/Source/Org is retired or inactive or all official music is released
        #Up to Date - Ongoing series, artist or org is still making music, but all known music is added
        #Ignored - Who cares about this artist/source/org
        #Partial - Has been looked at and a few albums added, need to be finished
        #Hidden - Actually hidden from viewing. redirects to alias. E.G. maaya -> maaya sakamoto
    #Credits/CreditsAbbr are used for ArtistSong and ArtistAlbum credits
      #Database categories
        Credits = %w[Composer Arranger Performer Lyricist FeatComposer FeatArranger FeatPerformer Chorus Instrumentals]  
      #Abbreviations for edting
        CreditsAbbr = %w[Comp Arr Perf Lyr FComp FArr FPerf Chorus Instr.]  
      #Fulls for display
        CreditsFull = {'Composer' =>'Composers', 'Arranger' => 'Arrangers', 'Performer' => 'Performers', 'Lyricist' =>'Lyricists', 'FeatComposer' => 'Featured Composers', 'FeatArranger' => 'Featured Arrangers', 'FeatPerformer' => 'Featured Performers', 'Chorus' => 'Chorus', 'Instrumentals' => 'Instrumentals'}
  
    SelfRelationships = [['is an alias of', '-Alias'],
    ['has an alias called', 'Aliases', 'Aliases', true, true, 'Alias'],
    ['is a member of', '-Member'], #aka Unit
    ['has the member', 'Members', 'Member Of', false, true, 'Member'],
    ['is a subunit of', '-Subunit'],
    ['has the subunit',  'Subunits', 'Subunit of', 'Subunit'],
    ['formerly known as', 'Formerly Known As', 'Now Known As', true, true, 'Former Alias'],
    ['is now known as', '-Former Alias'],
    ['is a former member of', '-Former Member'], #aka Former Unit
    ['had the former member', 'Former Members', 'Former Member Of','Former Member'],
    ['provided the voice of','Voices', 'Voiced by', 'Voice'],
    ['is the voide of','-Voice']]

    FullUpdateFields = {reference: true,
                        relations_by_id: {organization: [:new_organization_ids, :new_organization_categories, :update_artist_organizations, :remove_artist_organizations, ArtistOrganization, "artist_organizations"]},
                        self_relations: [:new_related_artist_ids, :new_related_artist_categories, :update_related_artists, :remove_related_artists],
                        images: ["id", "artistimages/", "Primary"], 
                        dates: ["birth_date", "debut_date"]}  
  #Validation
    validates :name, presence: true, uniqueness: {scope: [:reference]}
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Artist::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Artist::Categories, allow_nil: true, allow_blank: true
    validates :birth_date, presence: true, unless: -> {self.birth_date_bitmask.nil?}
    validates :birth_date_bitmask, presence: true, unless: -> {self.birth_date.nil?}
    validates :debut_date, presence: true, unless: -> {self.debut_date_bitmask.nil?}
    validates :debut_date_bitmask, presence: true, unless: -> {self.debut_date.nil?}
  
  #Associations
    #Primary Associations
      has_many :related_artist_relations1, class_name: 'RelatedArtists', foreign_key: 'artist1_id', :dependent => :destroy
      has_many :related_artist_relations2, class_name: 'RelatedArtists', foreign_key: 'artist2_id', :dependent => :destroy
      has_many :related_artists1, :through => :related_artist_relations1, :source => :artist2
      has_many :related_artists2, :through => :related_artist_relations2, :source => :artist1
 
      def related_artist_relations
        related_artist_relations1 + related_artist_relations2
      end

      def related_artists
        related_artists1 + related_artists2
      end    
            
      has_many :artist_albums, dependent: :destroy
      has_many :albums, through: :artist_albums
      
      has_many :artist_organizations, dependent: :destroy
      has_many :organizations, through: :artist_organizations
      
      has_many :artist_songs, dependent: :destroy
      has_many :songs, through: :artist_songs
    
    #Secondary Associations    
      has_many :taglists, as: :subject
      has_many :tags, through: :taglists, dependent: :destroy
      
      has_many :imagelists, as: :model, dependent: :destroy  
      has_many :images, through: :imagelists
      has_many :primary_images, through: :imagelists, source: :image, conditions: "images.primary_flag = 'Primary'" 

      has_many :postlists, dependent: :destroy, as: :model
      has_many :posts, through: :postlists
         
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
        text :namehash,  :boost => 5
        text :name, :altname
        text :reference
      end
  
  #For Artist and Album/Song Relationship categories
    def self.get_bitmask(credits)
      credits = [credits] if credits.class != Array
      (credits & Artist::Credits).map { |r| 2**(Artist::Credits).index(r) }.sum
    end
    
    def self.get_credits(bitmask)
      bitmask = bitmask.to_i if bitmask.class == String
      (Artist::Credits).reject { |r| ((bitmask || 0 ) & 2**(Artist::Credits).index(r)).zero?}
    end
  

end
