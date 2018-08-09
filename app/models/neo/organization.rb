class Neo::Organization
  include NodeModule

  has_many :in, :albums, rel_class: 'Neo::AlbumOrganization', model_class: 'Neo::Album'
  has_many :in, :artists, rel_class: 'Neo::ArtistOrganization', model_class: 'Neo::Artist'
  has_many :in, :sources, rel_class: 'Neo::SourceOrganization', model_class: 'Neo::Source'
  has_many :in, :tags, rel_class: 'Neo::Taglist', model_class: 'Neo::Tag'

  has_many :out, :organization_relations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Organization'
  has_many :in, :related_organizations, rel_class: 'Neo::RelatedRecord', model_class: 'Neo::Organization'

  property 'synopsis'
  property 'activity'
  property 'info'
  property 'established'
  property 'type of org'
end
