class Neo::Song
  include NodeModule

  Type_name = "Is In"

  has_many :out, :albums, type: Neo::Song::Type_name, model_class: 'Neo::Album'
  has_many :in, :artists, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Artist'
  has_many :out, :sources, rel_class: 'Neo::SongSource', model_class: 'Neo::Source'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  has_many :out, :song_relations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Song'
  has_many :in, :related_songs, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Song'


  property 'track number'
  property 'disc number'
  property 'length'
  property 'release date'
  property 'info'
  property 'lyrics'

  def album #doesn't work for unsaved songs
    albums.first
  end
end
