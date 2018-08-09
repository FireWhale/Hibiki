class Neo::Artist
  include NodeModule

  has_many :out, :albums, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Album'
  has_many :out, :songs, rel_class: 'Neo::ArtistAlbum', model_class: 'Neo::Song'
  has_many :out, :organizations, rel_class: 'Neo::ArtistOrganization', model_class: 'Neo::Organization'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  has_many :out, :artist_relations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Artist'
  has_many :in, :related_artists, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Artist'


  property 'synopsis'
  property 'activity'
  property 'info'
  property 'birth place'
  property 'blood type'
  property 'gender'
  property 'debut date'
  property 'birth date'
  property 'type of artist'

end
