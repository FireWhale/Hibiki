class Neo::RelatedRecord
  include RelModule

  from_class :any
  to_class :any
  type 'Is Related To'

  property 'Relationship'
end