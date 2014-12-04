class Album < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :altname, :namehash, :catalog_number, #Names!
                    :status, :classification,
                    :reference, :info, :private_info, 
                    :release_date, :release_date_bitmask #bitmask is needed for scraping
    attr_accessor   :flag, :list_text
    
    serialize :reference
    serialize :namehash
    
  #Modules
    include FormattingModule

  #Callbacks/Hooks
    
   
  #Multiple Model Constants - Put here for lack of a better place
    ReferenceLinks = [['vgmdb.net',:VGMdb], ['Last.FM',:lastpppfm], #seriously, going to sub ppp for a period
    ['Generasia Wiki',:generasia_wiki], ['Wikipedia.org',:wikipedia], 
    ['jpopsuki.eu',:jpopsuki], ['vndb.org',:visual_novel_database], 
    ['Anime News Network', :anime_news_network],
    ['Vocaloid wiki', :vocaloid_wiki],['Utaite wiki', :utaite_wiki],
    ['Touhou wiki', :touhou_wiki], ['Vocaloid db', :vocaloid_DB],
    ['Utaite db', :utaite_DB],
    ['Circus-co.jp',:circuspppco],['Comiket Website', :comiket],
    ['Official Website', :official],
    ['MyAnimeList', :myAnimeList],['IMDb', :iMDb],
    ['cdJapan', :CDJapan],
    ['Official Blog', :official_blog],
    ['Twitter', :twitter],
    ['Other', :other_reference ]]
    
    Status = ['Released', 'Unreleased', 'Hidden', 'Private']
      #Hidden - Just a placeholder in the database - maaya => maaya sakamoto
      #Private - Things that are out of scope of the database but I still like
      
  #Model Constants    
    SelfRelationships = [['is a limited edition of', "Normal Versions", "Limited Editions", 'Limited Edition'],
    ['has the limited edition', '-Limited Edition'],
    ['is a reprint of', "Reprinted From", "Reprints", 'Reprint'],
    ['has the reprint', '-Reprint'],
    ['is an alternate printing of', "Alternate Printings", "Alternate Printings", 'Alternate Printing'], #Alternate printings = same songs
    ['has the alternate printing', '-Alternate Printing'],
    ['is in the same collection as', "Same Series", "Same Series", 'Collection'],
    ['is an alternate version of', "Alternate Printings", "Alternate Printings", 'Alternate Version'], #Alt versions = slightly different songs
    ['is an instrumental version of', "Normal Versions", "Instrumental Versions", 'Instrumental'],
    ['has the instrumental version', '-Instrumental']]

    FullUpdateFields = {reference: true, events: true, songs: true, sources_for_album: true, artists_for_album: [:new_artist_ids, :new_artist_categories, :update_artist_albums],
                        scrapes: {organization: [:new_organization_names, :new_organization_categories_scraped],
                                  sources: [:new_source_names],
                                  artists: [:new_artist_names, :new_artist_categories_scraped]},
                        relations_by_id: {organization: [:new_organization_ids, :new_organization_categories, :update_album_organizations, :remove_album_organizations, AlbumOrganization, "album_organizations"]},
                        self_relations: [:new_related_album_ids, :new_related_album_categories, :update_related_albums, :remove_related_albums],
                        images: ["album", "albumart/", "Cover"], 
                        dates: ["release_date"]}
                        
    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :name, label: "Name:"}, 
                  {type: "text", attribute: :altname, label: "Alternate Name:"}, 
                  {type: "text", attribute: :catalog_number, label: "Catalog Number:"}, 
                  {type: "date", attribute: :release_date, label: "Release Date:"}, 
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "text", attribute: :classification, label: "Classification:"}, 
                  {type: "references"}, {type: "events"}, {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Album Relationships", sub_div_id: "Albums"},
                  {type: "artist_relations", div_class: "well", title: "Artist Relationships", sub_div_id: "Artists"} ,
                  {type: "related_model", div_class: "well", title: "Source Relationships", model: "source", relation_model: "album_sources", sub_div_id: "Sources"},
                  {type: "related_model", div_class: "well", title: "Organization Relationships", model: "organization", relation_model: "album_organizations", categories: AlbumOrganization::Categories, sub_div_id: "Organizations"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"}, {type: "songs", title: "Songs", div_class: "well", sub_div_id: "Songs"},
                  {type: "markup", tag_name: "/div"}]


    #Tracklist options is a tricky variable
    #It needs to be stored in the user's preference as a bitmask, so add only to the end.
    #I have 2 fields within each value. 
    #Params options: What is sent in params <--key value (only one short enough xd)
    #Description: What is displayed to the user as a description of the option
    #In the controller, we'll match the params options to what it corresponds to in 
    #Hibiki's database and what it corresponds to in foobar
    TracklistOptions = {:disc_number => 'Disc numbers', :track_number => 'Track numbers',
      :title => 'Titles', :performers => 'Performers as artists (requires split artist)',
      :composers => 'Composers (requires split composers)',
      :performer_field => 'Performers as performers (requires split performer)',
      :album => "Album name", :sources => 'Source Material (requires split source)', 
      :year => 'Date (yyyy)', :full_date => 'Date (yyyy-mm-dd)', 
      :op => 'OP/ED/Insert Field', :genres => 'Genres', :catalog_number => 'Catalog Number',
      :events => 'Events (requires split event)', :arrangers => "Arrangers (requires split arrangers)"
      }
    #Artistreplace is used to replace names with IDs when adding artists by name to an album.
    #Since adding by name only applies to scrapes, we need a way to differeniate artists
    #with the same name. This will give a "default" ID to use, as well as keep track of
    #artists with the same name. 
    Artistreplace = [
      ['SHIHO', 39004 ], #2 artists. I've Sound SHIHO (39004) in favor of Stereopony SHIHO(3221)
      ['96', 39007 ], #2 artists. IOSYS guitarist (39007) in favor of guitarfreak's 96 (868))
      ['AKINO', 432 ], #2 artists. bless4 singer (432) in favor of 2nd Flush arranger (39017))
      ['Takashi', 4326 ], #3 artists. all pretty defunct. macado (3932), Birth Entertainment (4326), and touhouist (39019)
      ['void', 225 ], #IOSYS arranger (225) in favor of Divere Systems/Trance void (39102)
      ['Vivienne', 402 ], #Amateras singer (402) in favor of FELT singer (39103). Will probably need to check anyhow.
      ['Lily', 1901 ], #real life partner of morrigan (1901) in favor of vocaloid (41078)
      ['JIN', 1434 ], #Vocaloid producer over Musician and Beatmania Singer
      ['Peco', 5927] #Liz Triangle artist over some 1997 ost artist 
    ]
    
    #Ignore Artist Names - for ignoring certain names when scraping, particulary organizations in parenthesis
    IgnoredArtistNames = [" ()", ")", "()", " (", '(Elements Garden)', '(Angel Note)', "(CROW'SCLAW)", '(C9)']
    
  #Validation
    validates :name, presence: true 
    validates :status, presence: true
    validates :catalog_number, presence: true, uniqueness: {scope: [:name, :release_date]}
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}
   
  #associations
    #Primary Associations
      has_many :related_album_relations1, class_name: 'RelatedAlbums', foreign_key: 'album1_id', :dependent => :destroy
      has_many :related_album_relations2, class_name: 'RelatedAlbums', foreign_key: 'album2_id', :dependent => :destroy
      has_many :related_albums1, through: :related_album_relations1, :source => :album2
      has_many :related_albums2, through: :related_album_relations2, :source => :album1
     
      def related_album_relations
        related_album_relations1 + related_album_relations2
      end

      def related_albums
        related_albums1 + related_albums2
      end
              
      has_many :album_sources
      has_many :sources, through: :album_sources, dependent: :destroy
      
      has_many :artist_albums
      has_many :artists, through: :artist_albums, dependent: :destroy
      
      has_many :album_organizations
      has_many :organizations, through: :album_organizations, dependent: :destroy

      has_many :songs, dependent: :destroy
      
    #Secondary Associations
      has_many :taglists, :as => :subject
      has_many :tags, through: :taglists, dependent: :destroy
    
      has_many :imagelists, :as => :model
      has_many :images, through: :imagelists, dependent: :destroy
      has_many :primary_images, through: :imagelists, :source => :image, :conditions => "images.primary_flag = 'Cover'" 

      has_many :postlists, dependent: :destroy, as: :model
      has_many :posts, through: :postlists
            
      has_many :album_events
      has_many :events, through: :album_events, dependent: :destroy
      
    #User Aassociations
      has_many :collections, dependent: :destroy
      has_many :collectors, through: :collections, source: :user
  
  #Scopes
    scope :released, -> { where(status: "Released")}
    
  #Gem Stuff
    #Pagination
    paginates_per 50
  
    #Sunspot Searching
    searchable do
      text :name, :catalog_number, :altname, :namehash 
      text :reference
      time :release_date
    end
        

  #For sorting albums
    def week #For sorting by week
      self.release_date.beginning_of_week(start_day = :sunday)
    end
    
    def month #For sorting by month
      self.release_date.beginning_of_month
    end
    
    def year
      self.release_date.beginning_of_year
    end

  #Sees if the album is in a user's collection 
    def collected?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Collected"}.map(&:user_id).include?(user.id)        
      end
    end
    
    def ignored?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Ignored"}.map(&:user_id).include?(user.id)
      end
    end
  
    def wishlist?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Wishlist"}.map(&:user_id).include?(user.id)
      end
    end
  
    def collected_category(user)
      #returns the type of album-user relationship 
      #if not in collection, returns "" (empty)
      if user.nil? || self.collections.select { |a| a.user_id == user.id}.empty?
        ""
      else
        self.collections.select { |a| a.user_id == user.id}[0].relationship
      end
    end
  
  
  #Limited Edition and reprint check
    def limited_edition?
      self.related_album_relations1.map(&:category).include?("Limited Edition")
    end
  
    def reprint?
      self.related_album_relations1.map(&:category).include?("Reprint")
    end
    
    def alternate_printing?
      self.related_album_relations1.map(&:category).include?("Alternate Printing")      
    end
  
end