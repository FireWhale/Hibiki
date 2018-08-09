class Neo::Song
  include NodeModule

  Type_name = "Is In"

  has_many :out, :albums, rel_class: 'Neo::Song', model_class: 'Neo::Album'
  has_many :in, :artists, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Artist'
  has_many :out, :sources, rel_class: 'Neo::SongSource', model_class: 'Neo::Source'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  def album #doesn't work for unsaved songs
    albums.first
  end
end
