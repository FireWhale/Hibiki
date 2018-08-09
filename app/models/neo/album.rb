class Neo::Album
  include NodeModule

  has_many :in, :songs, type: Neo::Song::Type_name, model_class: 'Neo::Song'
  has_many :out, :events, rel_class: 'Neo::AlbumEvent', model_class: 'Neo::Event'
  has_many :out, :organizations, rel_class: 'Neo::AlbumOrganization', model_class: 'Neo::Organization'
  has_many :out, :sources, rel_class: 'Neo::AlbumSource', model_class: 'Neo::Source'
  has_many :in, :artists, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Artist'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  has_many :out, :album_relations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Album'
  has_many :in, :related_albums, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Album'

end