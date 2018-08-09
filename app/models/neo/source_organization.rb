class Neo::SourceOrganization
  include RelModule

  from_class 'Neo::Source'
  to_class 'Neo::Organization'
  type 'Source Handled by'

  property 'Company Role'
end