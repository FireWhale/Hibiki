class Neo::Taglist
  include RelModule

  from_class 'Neo::Tag'
  to_class :any
  type 'Tagged'

end