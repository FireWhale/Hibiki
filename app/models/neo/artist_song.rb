class Neo::ArtistSong
  include RelModule

  from_class 'Neo::Artist'
  to_class 'Neo::Song'
  type 'Worked On Song'

  property 'Composer'
  property 'Performer'
  property 'Lyricist'
  property 'Arranger'
  property 'Chorus'
  property 'Instrumentals'
  property 'Credited As'

end