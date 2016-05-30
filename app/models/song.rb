class Song < ActiveRecord::Base
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
      include CollectionModule

  #Attributes
    serialize :namehash
    
    attr_accessor :new_sources
    attr_accessor :update_song_sources
    attr_accessor :remove_song_sources
    
    attr_accessor :new_artists
    attr_accessor :update_artist_songs
        
  #Callbacks/Hooks
    before_save :pull_data_from_album
    before_save :format_track_number
    after_save :manage_sources
    after_save :manage_artists
  
  #Constants
    SelfRelationships = [['is the same song as', 'Same Song', 'Same Song', 'Same Song'],
      ['is arranged as', 'Arranged As', 'Arranged From', 'Arrangement'],
      ['is arranged from', '-Arrangement'],
      ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version']] 
    
    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "date", attribute: :release_date, label: "Release Date:"},
                  {type: "text", attribute: :track_number, label: "Track Number:"},
                  {type: "text", attribute: :disc_number, label: "Disc Number:"},
                  {type: "text", attribute: :length, label: "Length (mm:ss or seconds):"},
                  {type: "references"}, {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "language_fields", attribute: :info},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Song Relationships", sub_div_id: "Songs"},
                  {type: "artist_relations", div_class: "well", title: "Artist Relationships", sub_div_id: "Artists"},
                  {type: "source_relations", div_class: "well", title: "Source Relationships", sub_div_id: "Sources"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"}, 
                  {type: "markup", tag_name: "/div"}]
    
    TracklistEditFields = [{type: "markup", tag_name: "div class='well well-xsmall'"}, {type: "well_hide"},
                           {type: "text", attribute: :internal_name, no_div: true}, 
                           {type: "text", attribute: :disc_number, no_div: true, field_class: "input-xmini", label: "Disc #:"},
                           {type: "text", attribute: :track_number, no_div: true, field_class: "input-xmini", label: "Track #:"},
                           {type: "text", attribute: :length, no_div: true, label: "Length (mm:ss or seconds):"},
                           {type: "id", no_div: true, label: "ID:"},
                           {type: "markup", tag_name: "div ", add_id: true}, {type: "markup", tag_name: "div class='row'"}, {type: "markup", tag_name: "div class='col-md-4'"}, {type: "markup", tag_name: "br"},
                           {type: "namehash"}, 
                           {type: "language_fields", attribute: :name},
                           {type: "language_fields", attribute: :lyrics},
                           {type: "markup", tag_name: "/div"}, 
                           {type: "markup", tag_name: "div class='col-md-8'"}, {type: "markup", tag_name: "br"},
                           {type: "artist_relations", no_div: true}, {type: "source_relations", no_div: true},
                           {type: "self_relations", no_div: true}, {type: "tags", no_div: true},
                           {type: "markup", tag_name: "/div"},
                           {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "/div"},
                           {type: "markup", tag_name: "/div"}]
    
    TracklistEditFields1 = [["well"], ["toggle"], ["text-no-div", :name, "", "input-xlarge"], ["text-no-div", :track_number, "Track #:", "input-xmini"], 
        ["text-no-div", :length, "Length"], ["id", "ID:"],
                           ["row", "id"], ["col", "4"], ["namehash", "not nil"], ["text-area", :lyrics, 2],["end"], 
                           ["col", "8"], ["artist_relation", "not nil"], ["sources", "not nil"], ["self-relations", "not nil"], ["tags", "not nil"], ["end"], ["end"], ["end"]]                  

  #Validation - Meh, not needed I guess (4/19)
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :album, presence: true, unless: ->(song){song.album_id.nil?}
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}

  #Asscoiations
    #Primary Associations
      belongs_to :album
           
      has_many :artist_songs, dependent: :destroy
      has_many :artists, through: :artist_songs
      
      has_many :song_sources, dependent: :destroy
      has_many :sources, through: :song_sources
    
  #Scopes
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :no_album, -> { where(album_id: nil)}
    scope :in_date_range, ->(start_date, end_date) {where("songs.release_date >= ? and songs.release_date <= ? ", start_date, end_date)}
        
  #Gem Stuff
    #Pagination
      paginates_per 50
      
  def op_ed_insert
    #Returns an array if the song is OP/ED/Insert
    self.song_sources.map { |rel| rel.classification }
  end
  
  def disc_track_number
    unless self.track_number.nil?
      "#{(self.disc_number + ".") unless self.disc_number.nil? || self.disc_number == "0"}#{self.track_number}"
    else
      ""
    end    
  end
  
  def length_as_time
    unless self.length.nil? || self.length == 0
      Time.at(self.length).utc.strftime("%-M:%S") 
    end
  end
  
  private
    def format_track_number
      track_number = self.track_number
      unless track_number.nil?
        if track_number.include?(".")
          self.disc_number = track_number.split(".")[0] 
          self.track_number = track_number.split(".")[1]
        end
        self.track_number =  self.track_number.rjust(2,'0') if self.track_number.length < 2
      end    
    end
    
    def manage_sources
      self.manage_primary_relation(Source,SongSource)
    end
    
    def manage_artists
      self.manage_artist_relation
    end
    
    def pull_data_from_album
      unless self.album.nil? || self.album.release_date.nil? || self.album.release_date_bitmask.nil?
        self.release_date = self.album.release_date
        self.release_date_bitmask = self.album.release_date_bitmask
      end
    end

end
