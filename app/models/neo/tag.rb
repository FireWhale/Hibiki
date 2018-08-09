class Neo::Tag
  include NodeModule

  has_many :out, :albums, rel_class: 'Neo::Taglist', model_class: 'Neo::Album'
  has_many :out, :artists, rel_class: 'Neo::Taglist', model_class: 'Neo::Artist'
  has_many :out, :organizations, rel_class: 'Neo::Taglist', model_class: 'Neo::Organization'
  has_many :out, :sources, rel_class: 'Neo::Taglist', model_class: 'Neo::Source'
  has_many :out, :songs, rel_class: 'Neo::Taglist', model_class: 'Neo::Song'

  property 'info'

end
