class Neo::SongSource
  include RelModule

  from_class 'Neo::Song'
  to_class 'Neo::Source'
  type 'Song Used In'

  property 'Usage'
  property 'Episode Numbers'
  property 'OP #'
  property 'ED #'

end