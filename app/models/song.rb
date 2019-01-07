class Song < ApplicationRecord
  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
    include DateModule
    include NeoNodeModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include LogModule
      include TagModule
      include ReferenceModule
      include CollectionModule

  #Attributes
    serialize :namehash

  #Constants
    SelfRelationships = [['is the same song as', 'Same Song', 'Same Song', 'Same Song'],
      ['is arranged as', 'Arranged As', 'Arranged From', 'Arrangement'],
      ['is arranged from', '-Arrangement'],
      ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version']]

  #Validation - Meh, not needed I guess (4/19)
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :album, presence: true, unless: ->(song){song.album_id.nil?}

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

end
