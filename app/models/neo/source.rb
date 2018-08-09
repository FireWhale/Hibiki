class Neo::Source
  include NodeModule

  has_many :in, :albums, rel_class: 'Neo::AlbumSource', model_class: 'Neo::Album'
  has_many :in, :songs, rel_class: 'Neo::SongSource', model_class: 'Neo::Song'
  has_many :out, :sources, rel_class: 'Neo::SourceOrganization', model_class: 'Neo::Organization'
  has_many :out, :seasons, rel_class: 'Neo::SourceSeason', model_class: 'Neo::Season'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

end