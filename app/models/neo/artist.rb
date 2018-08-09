class Neo::Artist
  include NodeModule

  has_many :out, :albums, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Album'
  has_many :out, :songs, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Song'
  has_many :out, :organizations, rel_class: 'Neo::ArtistOrganization', model_class: 'Neo::Organization'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

end
