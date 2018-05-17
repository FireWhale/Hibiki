class Artist < ApplicationRecord

  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
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

    attr_accessor :new_organizations
    attr_accessor :update_artist_organizations
    attr_accessor :remove_artist_organizations

  #Callbacks/Hooks
    after_save :manage_organizations

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
        Credits = %w[Composer Arranger Performer Lyricist FeatComposer FeatArranger FeatPerformer Chorus Instrumentals FeatLyricist]
      #Abbreviations for edting
        CreditsAbbr = %w[Comp Arr Perf Lyr FComp FArr FPerf Chorus Instr. FLyr]
      #Fulls for display
        CreditsFull = {'Composer' =>'Composers', 'Arranger' => 'Arrangers', 'Performer' => 'Performers', 'Lyricist' =>'Lyricists', 'FeatComposer' => 'Featured Composers', 'FeatArranger' => 'Featured Arrangers', 'FeatPerformer' => 'Featured Performers', 'FeatLyricist' => 'Featured Lyricist', 'Chorus' => 'Chorus', 'Instrumentals' => 'Instrumentals'}

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
    ['is the voice of','-Voice']]

    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "select", attribute: :category, label: "Categories:", categories: Artist::Categories},
                  {type: "select", attribute: :activity, label: "Activity:", categories: Artist::Activity},
                  {type: "references"},
                  {type: "date", attribute: :debut_date, label: "Debut Date:"},
                  {type: "date", attribute: :birth_date, label: "Birth Date:"},
                  {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "language_fields", attribute: :info},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :synopsis, rows: 2, label: "Synopsis:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Artist Relationships", sub_div_id: "Artists"},
                  {type: "related_model", div_class: "well", title: "Organization Relationships", model: "organization", relation_model: "artist_organizations", categories: ArtistOrganization::Categories, sub_div_id: "Organizations"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}]

  #Validation
    validates :internal_name, presence: true
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
      has_many :artist_albums, dependent: :destroy
      has_many :albums, through: :artist_albums

      has_many :artist_organizations, dependent: :destroy
      has_many :organizations, through: :artist_organizations

      has_many :artist_songs, dependent: :destroy
      has_many :songs, through: :artist_songs

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :with_activity, ->(activities) {where('activity IN (?)', activities)}

  #Gem Stuff
    #Pagination
      paginates_per 50

  #For Artist and Album/Song Relationship categories
    def self.get_bitmask(credits)
      credits = [credits] if credits.class != Array
      (credits & Artist::Credits).map { |r| 2**(Artist::Credits).index(r) }.sum
    end

    def self.get_credits(bitmask)
      bitmask = bitmask.to_i if bitmask.class == String
      (Artist::Credits).reject { |r| ((bitmask || 0 ) & 2**(Artist::Credits).index(r)).zero?}
    end

  private
    def manage_organizations
      self.manage_primary_relation(Organization,ArtistOrganization)
    end
end
