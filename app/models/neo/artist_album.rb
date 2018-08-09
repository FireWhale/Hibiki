class Neo::ArtistAlbum
  include RelModule

  from_class 'Neo::Artist'
  to_class 'Neo::Album'
  type 'Worked On Album'

  property 'Composer'
  property 'Performer'
  property 'Lyricist'
  property 'Arranger'
  property 'Chorus'
  property 'Instrumentals'
  property 'Credited As'

end