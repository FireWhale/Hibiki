class Album < ActiveRecord::Base
  #Attributes
    attr_accessible :internal_name, :synonyms, :namehash, :catalog_number, #Names!
                    :status, :classification,
                    :reference, :info, :private_info, 
                    :release_date, :release_date_bitmask #bitmask is needed for scraping
    
    serialize :reference
    serialize :namehash
  
  #Default Scope
  
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
      include CollectionModule

  #Callbacks/Hooks
    before_validation :convert_names
    
   
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
                        languages: [:name, :info],
                        dates: ["release_date"]}
                        
    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
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
    validates :internal_name, presence: true 
    validates :status, presence: true
    validates :catalog_number, presence: true, uniqueness: {scope: [:internal_name, :release_date]}
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}
   
  #associations
    #Primary Associations                 
      has_many :album_sources
      has_many :sources, through: :album_sources, dependent: :destroy
      
      has_many :artist_albums
      has_many :artists, through: :artist_albums, dependent: :destroy
      
      has_many :album_organizations
      has_many :organizations, through: :album_organizations, dependent: :destroy

      has_many :songs, dependent: :destroy
      
    #Secondary Associations
      has_many :album_events
      has_many :events, through: :album_events, dependent: :destroy
        
  #Scopes  
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :in_date_range, ->(start_date, end_date) {where("albums.release_date >= ? and albums.release_date <= ? ", start_date, end_date)}
        
    #These following three scopes are necessary because with_aos handles nil differently
    scope :artist_proc, ->(artist_ids) {joins(:artist_albums).where('artist_albums.artist_id IN (?)', artist_ids).uniq}
    scope :source_proc, ->(source_ids) {joins(:album_sources).where('album_sources.source_id IN (?)', source_ids).uniq}
    scope :organization_proc, ->(organization_ids) {joins(:album_organizations).where('album_organizations.organization_id IN (?)', organization_ids).uniq}
    
    scope :with_artist, ->(artist_ids) { artist_proc(artist_ids) unless artist_ids.nil?}
    scope :with_source, ->(source_ids) { source_proc(source_ids) unless source_ids.nil?}
    scope :with_organization, ->(organization_ids) {organization_proc(organization_ids) unless organization_ids.nil?}
    scope :with_artist_organization_source, ->(artist_ids, organization_ids, source_ids) {from("((#{Album.artist_proc(artist_ids).to_sql}) union (#{Album.source_proc(source_ids).to_sql}) union (#{Album.organization_proc(organization_ids).to_sql})) #{Album.table_name} ").references(:artist_albums, :album_sources, :album_organizations) unless artist_ids.nil? && organization_ids.nil? && source_ids.nil?}
    
    #User Settings
    scope :filter_by_user_settings, ->(user) {collection_filter(user.id, Collection::Relationship - user.album_filter, user.id).without_self_relation_categories(user.album_filter) unless user.nil?}
    
  #Gem Stuff  
    #Pagination
    paginates_per 50        

  #For sorting albums
    def week(start_day = "sunday") #For sorting by week
      self.release_date? ? self.release_date.beginning_of_week(start_day.to_sym) : nil
    end
    
    def month #For sorting by month
      self.release_date? ? self.release_date.beginning_of_month : nil
    end
    
    def year
      self.release_date? ? self.release_date.beginning_of_year : nil
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