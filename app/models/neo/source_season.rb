class Neo::SourceSeason
  include RelModule

  from_class 'Neo::Source'
  to_class 'Neo::Season'
  type 'Appeared In'

  property 'Appeared As a'
end