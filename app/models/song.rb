class Song < ActiveRecord::Base
  attr_accessible :album_id, :category, :length, :lyrics, :name, :namehash, :tracknumber, :op_ed_number, :newartistnames, :newartistcategories, :newsongids, :newsongcategories
  
  serialize :namehash
  
  #Virtual Attributes
    attr_accessor :newartistnames, :newartistcategories, :newsources, :newsongids, :newsongcategories, :duration, :songsources
  
  include RelationsModule
  include FormattingModule
  
  # #Validation - Meh, not needed I guess (4/19)
  # validates :album_id, :presence => true
  
  SelfRelationships = [['is the same song as', 'Also Appears On', 'Also Appears On', 'Same Song'],
    ['is arranged as', 'Arranged As', 'Arranged From', 'Arrangement'],
    ['is arranged from', '-Arrangement'],
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version']] 

  #Asscoiations
    #Primary Associations
      belongs_to :album
      
      has_many :related_song_relations1, class_name: 'RelatedSongs', foreign_key: 'song1_id', :dependent => :destroy
      has_many :related_song_relations2, class_name: 'RelatedSongs', foreign_key: 'song2_id', :dependent => :destroy
      has_many :related_songs1, :through => :related_song_relations1, :source => :song2
      has_many :related_songs2, :through => :related_song_relations2, :source => :song1
    
      def related_song_relations
        related_song_relations1 + related_song_relations2
      end
      
      def related_songs
        related_songs1 + related_songs2
      end
      
      has_many :artist_songs
      has_many :artists, :through => :artist_songs, dependent: :destroy
      
      has_many :song_sources
      has_many :sources, :through => :song_sources, dependent: :destroy
    
    #Secondary Associations
      has_many :taglists, :as => :subject
      has_many :tags, :through => :taglists, dependent: :destroy
      
    #User Associations
      has_many :ratings
      has_many :users, :through => :ratings, dependent: :destroy
  
  #Gem Stuff
    #Pagination
      paginates_per 50
  
    #Sunspot Searching
      searchable do
        text :name, :namehash
      end
  
  #Recursive Lazy Loading for Self Relations
    #First, we need a method to call
    def related_song_tree
      #Initialize a hash
      list = {:song_ids => [self.id], :relation_ids => []}
      #Start recursively building the list
      self.related_song_relations.map do |rel|
        rel.recursive_grabber(list)
      end
      #dump out the list that's created
      list
    end
    
    #This is the recursive method, we have to keep track of songs and songids we've used
    def recursive_grabber(list)
      related_song_relations.map do |rel|
        if rel.category = "Same Song"
        #I don't actually need to load any songs yet. 
          if rel.song1.id == self.id
          else
          end
        end
      end    
    end
  
  #Factory Methods
    def self.full_update(keys, values)
      #This factory update method will address Song values, Artists, Sources, and Related Songs
      #Tags are actually completely javascript.
      #Inputs are key = ["ID1", "ID2"], values = [{values}, {values}]
      #First, address if it's only 1 key and value. Put it into an array with values
      if keys.class != Array
        keys = [keys]
      end
      if values.class != Array
        values = [values]
      end
      #Join and then loop through each 
      songupdates = keys.zip(values)
      songupdates.each do |info|
        #First, find the song!
        song = Song.find_by_id(info[0])
        if song.nil? == false
          #Push it off to full_update_attributes
          song.full_update_attributes(info[1])
        end
      end #Ends the each info loop
    end    
  
  def full_update_attributes(values)
    #Artists - Next, take out the values from the values hash
      #Regarding ArtistAlbums,
      #Since we can't track changes easily (erase an artist, add to another track = ???),
      #We have to look at all the songs again to figure out how ArtistAlbum changes.
      #Another option is to track changes and systematically add to a hash. The problem with tracking changes
      #would be if we ever use this method for partial track updates (Currently, this is only used in
      #the update tracklist method, which accounts for all songs). Without having all the tracks, a tracking
      #hash wouldn't find the othe tracks and might accidentally erase something otherwise needed.
      #Wait, the album info takes precedence over song info, so...we can only add info to the album
      #and never delete info from the album. We can just work ArtistAlbum into the ArtistSong code
      #First, handle existing ArtistSong Records
      artistsongs = values.delete :artistsongs
      #For each ArtistSong, Calculate and update category
      if artistsongs.nil? == false
        artistsongs.each do |k,v|
          artistsong = ArtistSong.find_by_id(k)
          if artistsong.nil? == false
            bitmask = Artist.get_bitmask(v)
            if bitmask == 0 #If bitmask == 0, then delete the ArtistSong record
              artistsong.destroy
            else
              ArtistSong.update(artistsong.id, :category => bitmask)
              #Update AlbumArtist with info
              albumartist = ArtistAlbum.where(:artist_id => artistsong.artist.id, :album_id => self.album.id)
              if albumartist.empty? #If can't find one, create it
                self.album.artist_albums.create(:artist_id => artistsong.artist.id, :category => bitmask)
              else
                #Grab the categories, merge them, get uniques. 
                albumartist = albumartist.first
                categories = Artist.get_categories(albumartist.category)
                uniquecategories = (v + categories).uniq
                albumbitmask = Artist.get_bitmask(uniquecategories)
                albumartist.update_attributes(:category => albumbitmask)
              end
            end                
          end
        end
      end
      #Next, handle new artists
      newartistids = values.delete :newartistids
      newartistcategories = values.delete :newartistcategories
      #Split and then zip the categories into the names
      if newartistids.nil? == false && newartistcategories.nil? == false
        newartistcategories.pop
        newartistcategories = newartistcategories.split { |i| i == "New Artist"}
        newartistsongs = newartistids.zip(newartistcategories)
        newartistsongs.each do |newartistsong|
          if newartistsong[0].empty? == false && newartistsong[1].empty? == false #no name or categories = no need to continue
            bitmask = Artist.get_bitmask(newartistsong[1])
            artist = Artist.find_by_id(newartistsong[0])
            if artist.nil? == false
              #Create the artist-song association
              self.artist_songs.create(:artist_id => artist.id, :category => bitmask)
              #update AlbumArtist as well
              albumartist = ArtistAlbum.where(:artist_id => artist.id, :album_id => self.album.id)
              if albumartist.empty? #If can't find one, create it
                self.album.artist_albums.create(:artist_id => artist.id, :category => bitmask)
              else
                #Grab the categories, merge them, get uniques, add to album.
                albumartist = albumartist.first
                categories = Artist.get_categories(albumartist.category)
                uniquecategories = (newartistsong[1] + categories).uniq
                albumbitmask = Artist.get_bitmask(uniquecategories)
                albumartist.update_attributes(:category => albumbitmask)
              end
            end
          end
        end
      end
    #Sources
      #First, update the existing sources
        #Update existing songsources with information.
        songsources = values.delete :songsources
        if songsources.nil? == false
          if songsources.keys.empty? == false
            SongSource.update(songsources.keys, songsources.values)
          end
        end
        
        #Grab the updatesources key and delete any that are checked.
        removedsources = values.delete :removesources
        if removedsources.nil? == false
          removedsources.each do |sourceid|
            self.sources.delete(Source.find_by_id(sourceid))
          end          
        end

      #Next, add new sources
        newsources = values.delete :newsources
        if newsources.nil? == false
          #Make sure there are ids
          if newsources[:ids].nil? == false
            #Zip them up
            sourceinfo = newsources[:ids].zip(newsources[:classification],newsources[:op_ed_number],newsources[:ep_numbers])           
            sourceinfo.each do |each|
              source = Source.find_by_id(each[0])
              if source.nil? == false
                self.song_sources.create(:source_id => each[0], :classification => each[1], :op_ed_number => each[2], :ep_numbers => each[3])
                #Check to see if source is already in album. If not, add it.
                albumsource = AlbumSource.where(:source_id => source.id, :album_id => self.album.id)
                if albumsource.empty? == true
                  self.album.album_sources.create(:source_id => source.id)
                end
              end
            end
          end
        end
          

    #Related Songs
      #First, handle new related songs
        #Grab the IDs and the categories:
        songids = values.delete :newsongids
        songcategories = values.delete :newsongcategories
        #Create the self relationships using the RelationsModule method
        if songids.nil? == false && songcategories.nil? == false
          self.create_self_relation(songids,songcategories,"Song") #Easy as pie
        end
      #Next, handle updating related songs.
        relatedsongs = values.delete :relatedsongs
        if relatedsongs.nil? == false
          self.update_related_model(relatedsongs.keys,relatedsongs.values,"Song")
        end
      #lastly, handle deleting related songs
        removerelatedsongs = values.delete :removerelatedsongs
        if removerelatedsongs.nil? == false
          self.delete_related_model(removerelatedsongs,"Song")
        end
    #Oh wait, we need to format duration/length and track numbers!    
      #Duration/Length - formats "3:55" into "235" aka seconds
        duration = values.delete :duration 
        if duration.include?(":")
          values[:length] = duration.split(":")[0].to_i * 60 +  duration.split(":")[1].to_i
        else
          values[:length] = duration
        end
      #Track numbers - formats "1.7" into "1.07" 
        tracknumber = values.delete :tracknumber
        if tracknumber.split(".")[1].length < 2
          tracknumber = tracknumber.split(".")[0] + "." + tracknumber.split(".")[1].rjust(2,'0')
        end
        values[:tracknumber] = tracknumber
    #FINALLY, update the key with the values
      self.update_attributes(values)
  end
  
  def format_method #for autocomplete
    self.id.to_s + " - " + self.name
  end    

  def op_ed_insert?
    #Returns a string if the song is OP/ED/Insters
    (self.song_sources.map { |rel| rel.classification } & SongSource::Relationship).join(", ")
  end

end
