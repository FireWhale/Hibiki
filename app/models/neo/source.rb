class Neo::Source
  include NodeModule

  has_many :in, :albums, rel_class: 'Neo::AlbumSource', model_class: 'Neo::Album'
  has_many :in, :songs, rel_class: 'Neo::SongSource', model_class: 'Neo::Song'
  has_many :out, :organizations, rel_class: 'Neo::SourceOrganization', model_class: 'Neo::Organization'
  has_many :out, :seasons, rel_class: 'Neo::SourceSeason', model_class: 'Neo::Season'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  has_many :out, :source_relations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Source'
  has_many :in, :related_sources, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Source'

  property 'synopsis'
  property 'activity'
  property 'release date'
  property 'end date'
  property 'plot summary'
  property 'info'

end