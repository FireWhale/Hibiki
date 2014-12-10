class Song < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :altname, :namehash, #Names!
                    :status, :reference, :info, :private_info, #Database and Info
                    :track_number, :disc_number, :length, :lyrics, #more detailed info!
                    :release_date, :album_id #Dates and album ID
    attr_accessor   :duration #for editing a song
    
    serialize :namehash
    serialize :reference
    
  #Modules
    include FormattingModule

  #Callbacks/Hooks
    before_save :format_track_number
  
  #Constants
    SelfRelationships = [['is the same song as', 'Also Appears On', 'Also Appears On', 'Same Song'],
      ['is arranged as', 'Arranged As', 'Arranged From', 'Arrangement'],
      ['is arranged from', '-Arrangement'],
      ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version']] 

    FullUpdateFields = {reference: true, sources_for_song: true, lengths: true, artists_for_song: [:new_artist_ids, :new_artist_categories, :update_artist_songs],
                        self_relations: [:new_related_song_ids, :new_related_song_categories, :update_related_songs, :remove_related_songs],
                        images: ["id", "songimages/", "Primary"],
                        dates: ["release_date"],
                        language_records: {:lyric => "lyrics"}}
    
    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :name, label: "Name:"}, 
                  {type: "text", attribute: :altname, label: "Alternate Name:"},
                  {type: "text", attribute: :album_id, label: "Album ID:"},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "date", attribute: :release_date, label: "Release Date:"},
                  {type: "text", attribute: :track_number, label: "Track Number:"},
                  {type: "text", attribute: :disc_number, label: "Disc Number:"},
                  {type: "text", attribute: :length, label: "Length:"},
                  {type: "references"}, {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Song Relationships", sub_div_id: "Songs"},
                  {type: "artist_relations", div_class: "well", title: "Artist Relationships", sub_div_id: "Artists"},
                  {type: "source_relations", div_class: "well", title: "Source Relationships", sub_div_id: "Sources"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"}, 
                  {type: "language_records", title: "Lyrics", div_class: "well", sub_div_id: "Lyrics", model: "lyric", text_area: "lyrics"},
                  {type: "markup", tag_name: "/div"}]
    
    TracklistEditFields = [{type: "markup", tag_name: "div class='well well-xsmall'"}, {type: "well_hide"},
                           {type: "text", attribute: :name, no_div: true}, 
                           {type: "text", attribute: :disc_number, no_div: true, field_class: "input-xmini", label: "Disc #:"},
                           {type: "text", attribute: :track_number, no_div: true, field_class: "input-xmini", label: "Track #:"},
                           {type: "text", attribute: :length, no_div: true, label: "Length:"},
                           {type: "id", no_div: true, label: "ID:"},
                           {type: "markup", tag_name: "div ", add_id: true}, {type: "markup", tag_name: "div class='row'"}, {type: "markup", tag_name: "div class='col-md-4'"}, {type: "markup", tag_name: "br"},
                           {type: "namehash"}, 
                           {type: "language_records", no_div: true, model: "lyric", text_area: "lyrics"},
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
    validates :name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :name, uniqueness: {scope: [:reference]}, if: ->(song){song.album.nil?}
    validates :album, presence: true, unless: ->(song){song.album_id.nil?}
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}

  #Asscoiations
    #Primary Associations
      belongs_to :album
      
      has_many :related_song_relations1, class_name: 'RelatedSongs', foreign_key: 'song1_id', dependent: :destroy
      has_many :related_song_relations2, class_name: 'RelatedSongs', foreign_key: 'song2_id', dependent: :destroy
      has_many :related_songs1, through: :related_song_relations1, source: :song2
      has_many :related_songs2, through: :related_song_relations2, source: :song1
    
      def related_song_relations
        related_song_relations1 + related_song_relations2
      end
      
      def related_songs
        related_songs1 + related_songs2
      end
      
      has_many :artist_songs, dependent: :destroy
      has_many :artists, through: :artist_songs
      
      has_many :song_sources, dependent: :destroy
      has_many :sources, through: :song_sources
    
    #Secondary Associations
      has_many :taglists, dependent: :destroy, as: :subject
      has_many :tags, through: :taglists

      has_many :imagelists, dependent: :destroy, as: :model
      has_many :images, through: :imagelists
      has_many :primary_images, through: :imagelists, source: :image, conditions: "images.primary_flag = 'Primary'" 

      has_many :postlists, dependent: :destroy, as: :model
      has_many :posts, through: :postlists
      
      has_many :lyrics, dependent: :destroy
      
    #User Associations
      has_many :ratings, dependent: :destroy
      has_many :raters, through: :ratings
  
  #Scopes
    scope :no_album, -> { where(album_id: nil)}
    scope :released, -> { where(status: "Released")}
    
  #Gem Stuff
    #Pagination
      paginates_per 50
  
    #Sunspot Searching
      searchable do
        text :name, :namehash
      end
  
  #Recursive Lazy Loading for Self Relations
    #First, we need a method to call
    # def related_song_tree
      # #Initialize a hash
      # list = {:song_ids => [self.id], :relation_ids => []}
      # #Start recursively building the list
      # self.related_song_relations.map do |rel|
        # rel.recursive_grabber(list)
      # end
      # #dump out the list that's created
      # list
    # end
#     
    # #This is the recursive method, we have to keep track of songs and songids we've used
    # def recursive_grabber(list)
      # related_song_relations.map do |rel|
        # if rel.category = "Same Song"
        # #I don't actually need to load any songs yet. 
          # if rel.song1.id == self.id
          # else
          # end
        # end
      # end    
    # end
#   
  
  def op_ed_insert
    #Returns an array if the song is OP/ED/Insert
    self.song_sources.map { |rel| rel.classification }
  end

  def format_track_number
    track_number = self.track_number
    unless track_number.nil?
      if track_number.include?(".")
        self.disc_number = track_number.split(".")[0] 
        self.track_number = track_number.split(".")[1]
      end
      if self.track_number.length < 2
        self.track_number =  self.track_number.rjust(2,'0')
      end
    end    
  end

end
