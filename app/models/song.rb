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
    include FullUpdateModule
    include SolrSearchModule
    include AutocompletionModule
    include LanguageModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include TagModule
      include CollectionModule

  #Callbacks/Hooks
    before_save :format_track_number
    before_validation :convert_names
  
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
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
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
                  #{type: "language_records", title: "Lyrics", div_class: "well", sub_div_id: "Lyrics", model: "lyric", text_area: "lyrics"},
                  {type: "markup", tag_name: "/div"}]
    
    TracklistEditFields = [{type: "markup", tag_name: "div class='well well-xsmall'"}, {type: "well_hide"},
                           {type: "text", attribute: :internal_name, no_div: true}, 
                           {type: "text", attribute: :disc_number, no_div: true, field_class: "input-xmini", label: "Disc #:"},
                           {type: "text", attribute: :track_number, no_div: true, field_class: "input-xmini", label: "Track #:"},
                           {type: "text", attribute: :length, no_div: true, label: "Length:"},
                           {type: "id", no_div: true, label: "ID:"},
                           {type: "markup", tag_name: "div ", add_id: true}, {type: "markup", tag_name: "div class='row'"}, {type: "markup", tag_name: "div class='col-md-4'"}, {type: "markup", tag_name: "br"},
                           {type: "namehash"}, 
                           #{type: "language_records", no_div: true, model: "lyric", text_area: "lyrics"},
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
    validates :internal_name, uniqueness: {scope: [:reference]}, if: ->(song){song.album.nil?}
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
    #Globalize
    translates :name, :info, :lyrics
    
    #Pagination
      paginates_per 50
  
    #Sunspot Searching
      searchable do
        text :internal_name, :synonyms, :namehash
      end
    
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
      if self.track_number.length < 2
        self.track_number =  self.track_number.rjust(2,'0')
      end
    end    
  end

  def convert_names
    @name_hash = self.namehash
    unless @name_hash.nil?
      #Compare entries in the namehash to remove duplicates
      unless @name_hash[:English].nil? && @name_hash[:Japanese].nil?
        if @name_hash[:English] == @name_hash[:Japanese]
          if @name_hash[:Japanese].contains_japanese?
            @name_hash[:English] = nil
          else
            @name_hash[:Japanese] = nil
          end
        end
      end
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
