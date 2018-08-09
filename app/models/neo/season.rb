class Neo::Season
  include NodeModule

  has_many :in, :sources, rel_class: 'Neo::SourceSeason', model_class: 'Neo::Source'

  property 'start date'
  property 'end date'

end
