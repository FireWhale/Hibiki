require 'rails_helper'

describe Song do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:song)
      expect(instance).to be_valid
    end

  #Shared Examples
    it_behaves_like "it has images", :song, Song
    it_behaves_like "it has tags", :song, Song
    it_behaves_like "it has posts", :song, Song
    it_behaves_like "it can be searched", :song, Song
    it_behaves_like "it can be autocompleted", :song
    it_behaves_like "it has pagination", "song"

  #Association Tests
    it_behaves_like "it has self-relations", :song, "song", RelatedSongs
    it_behaves_like "it has a primary relation", :song, "source", SongSource, :song_source
    it_behaves_like "it has a primary relation", :song, "artist", ArtistSong, :artist_song
      

    it "has many lyrics" do
      expect(create(:song, :with_lyric).lyrics.first).to be_a Lyric
      expect(Song.reflect_on_association(:lyrics).macro).to eq(:has_many)  
    end
    
    it "destroys it's songs when destroyed" do
      song = create(:song, :with_lyric)
      expect{song.destroy}.to change(Lyric, :count).by(-1)
    end
    
  #Validation Tests
    include_examples "is invalid without an attribute", :song, :name
    include_examples "is invalid without an attribute", :song, :status
    include_examples "name/reference combinations", :song

    include_examples "is invalid without an attribute in a category", :song, :status, Album::Status, "Album::Status"

    context "does not belong to an album" do
      it "is valid if it does not belong to an album" do
        expect(build(:song, album_id: nil)).to be_valid
      end
      
      it "is invalid with duplicate name/reference combinations" do
        create(:song, album_id: nil, name: "hi", reference: {ho: "hi"})
        expect(build(:song, album_id: nil, name: "hi", reference: {ho: "hi"})).to_not be_valid        
      end
      
    end
    
    context "belongs to an album" do
      it "is valid if it belongs to an album" do
        expect(build(:song, :with_album)).to be_valid
      end
      
      it "is not valid if it does not belong to a real album" do
        expect(build(:song, album_id: 99999999)).to_not be_valid
      end
      
      it "is valid with duplicate name/reference combinations" do
        create(:song, :with_album, name: "hi", reference: {ho: "hi"})
        expect(build(:song, :with_album, name: "hi", reference: {ho: "hi"})).to be_valid        
      end
      
    end

    it "is valid with lyrics" do
      song = create(:song)
      lyric1 = create(:lyric, :language => "English", song: song)
      lyric2 = create(:lyric, :language => "Japanese", song: song)
      expect(song.lyrics).to match_array([lyric1, lyric2])
    end
    
    it "is valid without lyrics" do
      #well the factory doesn't come with songs
      expect(create(:song)).to be_valid
    end

    include_examples "is valid with or without an attribute", :song, :altname, "hi"
    include_examples "is valid with or without an attribute", :song, :track_number, "hi"
    include_examples "is valid with or without an attribute", :song, :disc_number, "hi"
    include_examples "is valid with or without an attribute", :song, :length, 12323
    include_examples "is valid with or without an attribute", :song, :info, "DANCE"
    include_examples "is valid with or without an attribute", :song, :private_info, "DANCE"

    it_behaves_like "it has a partial date", :song, :release_date
    
    it "does not respond to op_ed_number" do
      expect(build(:song)).to_not respond_to("op_ed_number")
      expect(build(:song)).to_not respond_to("op_ed_number=")      
    end
        
     
      
  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :song, :reference
    it_behaves_like "it has a serialized attribute", :song, :namehash
    
  #Instance Method Tests
    context "op/ed/insert method" do 
      SongSource::Relationship.each do |category|  
        it "returns #{category} if the song is a #{category}" do
          song = create(:song)
          songsource = create(:song_source, classification: category, song: song)
          expect(song.op_ed_insert).to eq([category])
        end
      end
      
      it "returns an array if a song is an op and ed" do
        song = create(:song)
        songsource = create(:song_source, song: song, classification: "OP")
        songsource = create(:song_source, song: song, classification: "ED")
        expect(song.op_ed_insert).to match_array(["OP", "ED"])
      end
      
      it "returns empty if the song is not an op/ed/insert" do
        song = create(:song)
        expect(song.op_ed_insert).to be_empty
        expect(song.op_ed_insert).to be_a Array
      end
      
    end
    
  #Callback Tests   
    
    context "has a full update method" do
      include_examples "updates with keys and values", :song
      include_examples "updates the reference properly", :song
      include_examples "can upload an image", :song
      include_examples "can update a language record", :song, "lyric", "lyrics"
      
      context "updates artists" do
        it "creates an artist_song" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "New Artist"])
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(1)
          expect(song.artists.first.name).to eq("hihi")
          expect(song.artist_songs.first.category).to eq("4")
        end
        
        
        it "creates an album_artist" do
          song = create(:song, :with_album)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "New Artist"])
          expect{song.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(1)
        end
        
        it "adds to the current album_artist" do
          album = create(:album)
          song = create(:song, album: album)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 1)
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "New Artist"])
          expect{song.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)
          expect(album.artist_albums.first.category).to eq("5")
        end
        
        it "handles multiple categories" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "Composer", "New Artist"])
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(1)
          expect(song.artists.first.name).to eq("hihi")
          expect(song.artist_songs.first.category).to eq("5")
        end
        
        
        it "can create multiple artist_songs" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist2 =create(:artist, name: 'hoho')
          attributes.merge!(:new_artist_ids => [artist.id.to_s, artist2.id.to_s], :new_artist_categories => ["Performer", "Composer", "New Artist", "Performer", "New Artist" ])
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(2)
          expect(song.artists.first.name).to eq("hihi")
          expect(song.artist_songs.first.category).to eq("5")
          expect(song.artists[1].name).to eq("hoho")
          expect(song.artist_songs[1].category).to eq("4")
        end
        
        it "does not create artist_songs if it doesn't exist" do
          song = create(:song)
          attributes = attributes_for(:song)
          attributes.merge!(:new_artist_ids => ["999999"], :new_artist_categories => ["Performer", "Composer", "New Artist"])
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(0)
        end
        
        it "updates artist_songs" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => ["Performer", "Arranger", "Composer"]})
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(0)
          expect(song.artist_songs.first.category).to eq("7")
        end
        
        it "updates artist_albums" do
          album = create(:album)
          song = create(:song, album: album)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          album.artist_albums.first.update_attributes(category: 20) #just by making artist_song, we've made an artist_album
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => ["Performer", "Arranger", "Composer"]})
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(0)
          expect(song.artist_songs.first.category).to eq("7")
          expect(album.artist_albums.first.category).to eq("23")
        end
        
        it "updates multiple artist_songs" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist2 = create(:artist, name: 'hihooi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          artist_song2 = create(:artist_song, song: song, artist: artist2, category: 44)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => ["Performer", "Arranger", "Composer"], artist_song2.id.to_s => ["Composer", "FeatArranger"]})
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(0)
          expect(song.artist_songs.first.category).to eq("7")
          expect(song.artist_songs[1].category).to eq("33")          
        end
        
        it "destroys artist_songs" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => []})
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(-1)
        end
        
        it "does not destroy album_artists" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => []})
          expect{song.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)          
        end
        
        it "doesn't destroy artists" do
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => []})
          expect{song.full_update_attributes(attributes)}.to change(Artist, :count).by(0)          
        end
        
        it "destroy multiple artist_song" do 
          song = create(:song)
          attributes = attributes_for(:song)
          artist = create(:artist, name: 'hihi')
          artist2 = create(:artist, name: 'hihooi')
          artist_song = create(:artist_song, song: song, artist: artist, category: 33)
          artist_song2 = create(:artist_song, song: song, artist: artist2, category: 44)
          attributes.merge!(:update_artist_songs => {artist_song.id.to_s => [], artist_song2.id.to_s => []})
          expect{song.full_update_attributes(attributes)}.to change(ArtistSong, :count).by(-2)
        end
      end
      
      context "updates sources" do 
        before(:each) do 
          @song = create(:song)
          @attributes = attributes_for(:song)
          @source = create(:source, name: "this is a name")
        end
        
        it "creates a song_source" do
          song = create(:song)
          source = create(:source, name: "hello")
          attributes = attributes_for(:song)
          attributes.merge!(:new_sources => {"ids" => [source.id]})
          expect{song.full_update_attributes(attributes)}.to change(SongSource, :count).by(1)
          expect(song.reload.sources.first.name).to eq("hello")
        end

        it "creates an album_source" do
          album= create(:album)
          @song = create(:song, album: album)
          @attributes.merge!(:new_sources => {"ids" => [@source.id]})
          expect{@song.full_update_attributes(@attributes)}.to change(AlbumSource, :count).by(1)
          expect(@song.album.sources.first.name).to eq("this is a name")
        end
        
        it "does not create a new album_source if one exists" do
          @attributes.merge!(:new_sources => {"ids" => [@source.id]})
          expect{@song.full_update_attributes(@attributes)}.to change(AlbumSource, :count).by(0)
        end
        
        it "passes op/classification/ep numbers" do
          @attributes.merge!(:new_sources => {"ids" => [@source.id], "classification" => ["OP"], "op_ed_number" => ["2"], "ep_numbers" => ["5-8"]})
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(1)
          expect(@song.song_sources.first.classification).to eq("OP")
          expect(@song.song_sources.first.op_ed_number).to eq("2")
          expect(@song.song_sources.first.ep_numbers).to eq("5-8")
        end
        
        it "creates multiple song_sources" do
          source2 = create(:source)
          @attributes.merge!(:new_sources => {"ids" => [@source.id, source2.id]})
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(2)
        end
        
        it "does not create song_source if it doesn't exist" do
          @attributes.merge!(:new_sources => {"ids" => [@source.id, 99999999]})
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(1)
        end
        
        it "updates song_sources" do
          song_source = create(:song_source, song: @song, classification: "OP")
          @attributes.merge!(:update_song_sources => { song_source.id.to_s => {"classification" => "ED"}})
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(0)
          expect(@song.song_sources.first.classification).to eq("ED")
        end
        
        it "adds to album_source through update if for some reason it doesn't exist" do
          song_source = create(:song_source, song: @song, classification: "OP")
          album = create(:album)
          @song.update_attributes(:album_id => album.id)
          album.album_sources.first.delete unless album.album_sources.empty?
          @attributes.merge!(:update_song_sources => { song_source.id.to_s => {"classification" => "ED"}})
          expect{@song.full_update_attributes(@attributes)}.to change(AlbumSource, :count).by(1)
        end
        
        it "updates multiple song_sources" do 
          song_source = create(:song_source, song: @song, classification: "OP")
          song_source2 = create(:song_source, song: @song, classification: "ED")
          @attributes.merge!(:update_song_sources => { song_source.id.to_s => {"classification" => "ED"}, song_source2.id.to_s => {"classification" => "OP"}})
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(0)
          expect(@song.song_sources.first.classification).to eq("ED")          
          expect(@song.song_sources[1].classification).to eq("OP")          
        end
        
        it "destroys song_sources" do
          song_source = create(:song_source, song: @song, classification: "OP")
          @attributes.merge!(:remove_song_sources => [song_source.id.to_s])
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(-1)
        end
        
        it "does not destroy album_sources" do
          album = create(:album)
          song = create(:song, album: album)
          song_source = create(:song_source, song: song, classification: "OP")
          @attributes.merge!(:remove_song_sources => [song_source.id.to_s])
          expect{@song.full_update_attributes(@attributes)}.to change(AlbumSource, :count).by(0)
        end
        
        it "doesn't destroy sources" do
          album = create(:album)
          song = create(:song, album: album)
          song_source = create(:song_source, song: song, classification: "OP")
          @attributes.merge!(:remove_song_sources => [song_source.id.to_s])
          expect{@song.full_update_attributes(@attributes)}.to change(Source, :count).by(0)
        end
        
        it "destroys multiple song_sources" do
          album = create(:album)
          song = create(:song, album: album)
          song_source = create(:song_source, song: song, classification: "OP")
          song_source2 = create(:song_source, song: song, classification: "OP")
          @attributes.merge!(:remove_song_sources => [song_source.id.to_s, song_source2.id.to_s])
          expect{@song.full_update_attributes(@attributes)}.to change(SongSource, :count).by(-2)
        end      
          
      end
      include_examples "can update self-relations", :song
      include_examples "updates namehash properly", :song
      include_examples "updates dates properly", :song, "release_date"
      include_examples "updates with normal attributes", :song
     
    end       
    
    it "formats tracknumbers into a disc_number and track_number" do
      song = create(:song)
      song.update_attributes(:track_number => "4.39")
      expect(song.track_number).to eq("39")
      expect(song.disc_number).to eq("4")      
    end
    
    it "formats a track number of <10 into a disc_number and track_number" do
      song = create(:song)
      song.update_attributes(:track_number => "4.39")
      expect(song.track_number).to eq("39")
      expect(song.disc_number).to eq("4")      
    end
        
    it "formats the length aka duration into an integer" do
      song = create(:song)
      attributes = attributes_for(:song)
      attributes.merge!(:duration => "5:33")
      song.full_update_attributes(attributes)
      expect(song.length).to eq(333)
    end
    
  #Scope Tests
    it "returns a list of songs with no albums" do
      songlist = create_list(:song, 6, album: nil)
      songlist2 = create_list(:song, 3, :with_album)
      expect(Song.no_album).to eq(songlist)
    end
    
    it_behaves_like "it reports released records", :song

end


