class Song < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :altname, :namehash, #Names!
                    :status, :reference, :info, :private_info, #Database and Info
                    :track_number, :disc_number, :length, :lyrics, #more detailed info!
                    :release_date, :album_id #Dates and album ID
                    
    serialize :namehash
    serialize :reference
    
  #Modules
    include FormattingModule

  #Callbacks/Hooks
    
  
  #Constants
    SelfRelationships = [['is the same song as', 'Also Appears On', 'Also Appears On', 'Same Song'],
      ['is arranged as', 'Arranged As', 'Arranged From', 'Arrangement'],
      ['is arranged from', '-Arrangement'],
      ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version']] 

    FullUpdateFields = {reference: true, sources_for_song: true, track_numbers: true, artists_for_songs: [:new_artist_ids, :new_artist_categories, :update_artist_songs],
                        self_relations: [:new_related_song_ids, :new_related_song_categories, :update_related_songs, :remove_related_songs],
                        images: ["id", "songimages/", "Primary"],
                        dates: ["release_date"] }

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
      
    #User Associations
      has_many :ratings, dependent: :destroy
      has_many :raters, through: :ratings
  
  #Scopes
    scope :no_album, -> { where(album_id: nil)}
  
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
  
  def format_method #for autocomplete
    self.id.to_s + " - " + self.name
  end    

  def op_ed_insert
    #Returns an array if the song is OP/ED/Insert
    self.song_sources.map { |rel| rel.classification }
  end

end
