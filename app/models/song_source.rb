class SongSource < ApplicationRecord

  #Modules
  include NeoRelModule

  #Callbacks
    after_save :update_album

  #Constants
    Relationship = ['OP', 'ED', 'Insert', 'Theme Song']

  #Associations
    belongs_to :song
    belongs_to :source

  #Validations
    validates :source, presence: true
    validates :song, presence: true
    validates :classification, inclusion: SongSource::Relationship, allow_blank: true, allow_nil: true

    validates :source_id, uniqueness: {scope: [:song_id]}


  def update_album
    unless self.song.album.nil?
      album_source = self.song.album.album_sources.where(:source_id => self.source.id)
      self.song.album.album_sources.create(:source_id => source.id) if album_source.empty?
    end
  end

  def neo_relation
    neo_rel(song,source)
  end
end
