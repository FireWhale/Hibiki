require 'rails_helper'

describe Song do
  include_examples "global model tests" #Global Tests
  
  #Module Tests
    it_behaves_like "it has a language field", "name"
    it_behaves_like "it has a language field", "lyric"
    it_behaves_like "it can be solr-searched"
    it_behaves_like "it can be autocompleted"
    it_behaves_like "it has pagination"
    it_behaves_like "it has form_fields"
    
  #Association Tests
    it_behaves_like "it has images"
    it_behaves_like "it has posts"
    it_behaves_like "it has tags"
    it_behaves_like "it has self-relations"
    it_behaves_like "it has a primary relation", Source, SongSource
    it_behaves_like "it has a primary relation", Artist, ArtistSong
          
  #Validation Tests
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute",  :status
    include_examples "name/reference combinations"
    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"

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

    include_examples "is valid with or without an attribute", :altname, "hi"
    include_examples "is valid with or without an attribute", :track_number, "hi"
    include_examples "is valid with or without an attribute", :disc_number, "hi"
    include_examples "is valid with or without an attribute", :length, 12323
    include_examples "is valid with or without an attribute", :info, "DANCE"
    include_examples "is valid with or without an attribute", :private_info, "DANCE"

    
    it "does not respond to op_ed_number" do
      expect(build(:song)).to_not respond_to("op_ed_number")
      expect(build(:song)).to_not respond_to("op_ed_number=")      
    end    
      
  #Serialization Tests
    it_behaves_like "it has a partial date", :release_date
    it_behaves_like "it has a serialized attribute", :reference
    it_behaves_like "it has a serialized attribute", :namehash
    
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
    
    it "returns it's length as time" do
      #The method used is Time.at(x).utc.strf..., so we are doing it manually in the test.
      time = Array(1..999).sample
      song = create(:song, length: time)
      expect(song.length_as_time).to eq("#{time / 60}:#{(time % 60).to_s.rjust(2, '0')}") 
    end
    
    describe "has a disc_track_number method" do
      it "returns a disc and track number" do
        song = create(:song, disc_number: "1", track_number: "10")
        expect(song.disc_track_number).to eq("1.10")
      end
      
      it "doesn't return a disc number if disc_number is nil" do
        song = create(:song, disc_number: nil, track_number: "10")
        expect(song.disc_track_number).to eq("10")
      end
      
      it "doesn't return a disc number if disc_number is 0" do
        song = create(:song, disc_number: "0", track_number: "10")
        expect(song.disc_track_number).to eq("10")
      end
      
      it "doesn't return anything is track number is nil" do
        song = create(:song, disc_number: "1", track_number: nil)
        expect(song.disc_track_number).to eq("")
      end
      
      it "doesn't returns 0 if track number is 0" do
        song = create(:song, disc_number: "1", track_number: "0")
        expect(song.disc_track_number).to eq("1.00")
      end
    end 
    
    
  #Callback Tests   
    
    context "has a full update method" do
      include_examples "updates with keys and values"
      include_examples "updates the reference properly"
      include_examples "can upload an image"
     
      it "can update lyrics and/or names" #placeholder test
      #Note: Need to add it to all other relevant fields still
      #like album.name and source.name and event.name
      
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
      include_examples "can update self-relations"
      include_examples "updates namehash properly"
      include_examples "updates dates properly", "release_date"
      include_examples "updates with normal attributes"
     
    end       
    
    it "formats tracknumbers into a disc_number and track_number" do
      song = create(:song)
      song.update_attributes(:track_number => "4.39")
      expect(song.track_number).to eq("39")
      expect(song.disc_number).to eq("4")      
    end
    
    it "formats a track number of <10 into a disc_number and track_number" do
      song = create(:song)
      song.update_attributes(:track_number => "4.9")
      expect(song.track_number).to eq("09")
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
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by tag"   
    it_behaves_like "filters by date range", "release_date"
    it_behaves_like "filters by self relation categories"
    
    describe "filters by rating" do
      let(:song1) {create(:song)}
      let(:song2) {create(:song)}
      let(:song3) {create(:song)}
      let(:song4) {create(:song)}
      let(:song5) {create(:song)}
      let(:song6) {create(:song)}
      let(:user1) {create(:user)} #rated songs 1 and 2 (2 with string)
      let(:user2) {create(:user)} #rated song 3
      let(:user3) {create(:user)} #rated song 1 and 3 (with string)
      let(:user4) {create(:user)} #no songs
      before(:each) do
        create(:rating, song: song1, user: user1, favorite: "good")
        create(:rating, song: song2, user: user1)
        create(:rating, song: song3, user: user2)
        create(:rating, song: song4, user: user2, favorite: "eat")
        create(:rating, song: song1, user: user3, favorite: "good")
        create(:rating, song: song3, user: user3, favorite: "great")
        create(:rating, song: song4, user: user3, favorite: "great")
        create(:rating, song: song5, user: user3, favorite: "neat")
        create(:rating, song: song6, user: user3, favorite: "eat")
      end
      
      describe "has a rating record" do
        #method(user.id,favorite string)
        it "filters by having a rating record" do
          expect(Song.with_rating(user1.id)).to match_array([song1, song2])
        end
        
        it "returns no results if there are no matches" do
          expect(Song.with_rating(user4.id)).to match_array([])
        end
        
        it "filters by favorite string" do
          expect(Song.with_rating(user3.id, "great")).to match_array([song3, song4])
        end
         
        it "accepts multiple users (what's the point, though?)" do
          expect(Song.with_rating([user1.id, user2.id])).to match_array([song1, song2, song3, song4])
        end      
  
        it "accepts multiple users 2" do
          expect(Song.with_rating([user1.id, user3.id])).to match_array([song1, song2, song3, song4, song5, song6])
        end      
        
        it "only accepts full matches" do
          expect(Song.with_rating(user3.id, "eat")).to match_array([song6])
        end
        
        it "accepts an array of favorite strings" do
          expect(Song.with_rating(user3.id, ["neat", "eat"])).to match_array([song5, song6])
        end
        
        it "returns all if nil is provided" do
          expect(Song.with_rating(nil)).to match_array([song1, song2, song3, song4, song5, song6])
        end

        it "ignores the second param if nil is the first" do
          expect(Song.with_rating(nil, "eat")).to match_array([song1, song2, song3, song4, song5, song6])
        end
        
        
        it "ignores a nil favorite string" do
          expect(Song.with_rating(user1.id, nil)).to match_array([song1, song2])
        end
        
        it "is an active record relation" do
          expect(Song.with_rating(user3.id,"eat").class).to_not be_a(Array)
        end
      end
      
      describe "does not have a rating record" do
        it "removes records that are in the users rating" do
          expect(Song.without_rating(user1.id)).to match_array([song3, song4, song5, song6])          
        end
        
        it "removes records that are attached to any of many users" do
          expect(Song.without_rating([user1.id, user2.id])).to match_array([song5, song6])          
        end
        
        it "removes records based on either user" do
          create(:rating, song: song5, user: user1)
          expect(Song.without_rating([user1.id, user2.id])).to match_array([song6])          
        end
        
        it "returns all records if nil is passed in" do
          expect(Song.without_rating(nil)).to match_array([song1, song2, song3, song4, song5, song6])
        end

        it "is an active record relation" do
          expect(Song.without_rating(user3.id).class).to_not be_a(Array)
        end
      end
      
      #Maybe have another merged (UNION) scope here?
      
    end    
    
    describe "filters by user_settings" do
      describe "filters by albums" do
        it "wow this is gonna be some test"
      # let(:user1) {create :user}
      # let(:user2) {create :user}
      # let(:song1) {create :song, :with_album} #ignored album from user 1
      # let(:song2) {create :song, :with_album} #ignored album from user 2 
      # let(:song3) {create :song, :with_album} #limited edition of album 1
      # let(:song4) {create :song, :with_album} #reprint of album 2
      # let(:song5) {create :song, :with_album} #ignored album from user 1
      # let(:song6) {create :song, :with_album} #Watched album from user 1
      # let(:song7) {create :song, :with_album} #no relations, should always return
      # let(:song8) {create :song} #no album, should always return
      # before(:each) do
        # create(:collection, user: user1, album: song1.album, relationship: "Ignored")
        # create(:collection, user: user2, album: song2.album, relationship: "Ignored")
        # create(:collection, user: user1, album: song5.album, relationship: "Ignored")
        # create(:collection, user: user1, album: song6.album, relationship: "Wishlisted")
        # create(:related_albums, album1: song3.album, album2: song1.album, category: "Limited Edition")
        # create(:related_albums, album1: song4.album, album2: song2.album, category: "Reprint")        
      # end
      # #Testing song.album data
      # it "filters out songs belonging to an ignored album" do
        # user1.update_attribute("display_bitmask", 65) 
        # expect(Song.filter_by_user_settings(user1)).to match_array([song2,song3,song4,song6,song7,song8])
      # end
#       
      # it "filters out songs beloning to a album reprint" do
        # user1.update_attribute("display_bitmask", 5) 
        # expect(Song.filter_by_user_settings(user1)).to match_array([song1,song2,song3,song5,song6,song7,song8])        
      # end
#       
      # it "filters out songs belong to a limited edition album" do
        # user1.update_attribute("display_bitmask", 68) 
        # expect(Song.filter_by_user_settings(user1)).to match_array([song1,song2,song4,song5,song6,song7,song8])        
      # end
#       
      # it "filters out songs matching on LE but not reprint" do
        # user1.update_attribute("display_bitmask", 64) 
        # song9 = create(:album)
        # create(:related_albums, album1: song9.album, album2: song2.album, category: "Reprint")
        # create(:related_albums, album1: song4.album, album2: song1.album, category: "Limited Edition")
        # expect(Song.filter_by_user_settings(user1)).to match_array([song2,song6,song7,song8,song9])        
      # end
#       
      # it "filters out songs matching on ignored but not le" do
        # user1.update_attribute("display_bitmask", 1)
        # create(:collection, user: user1, album: song3.album, relationship: "Ignored")
        # create(:related_albums, album1: song6.album, album2: song1.album, category: "Limited Edition")
        # expect(Song.filter_by_user_settings(user1)).to match_array([song2,song6,song7,song8])        
      # end
#             
      # it "returns all if nil is passed in" do
        # expect(Song.filter_user_settings(nil)).to match_array([song1,song2,song3,song4,song5,song6,song7,song8])
      # end
#       
      # #testing song.data
      # it 
      
      
#       
#       
      # it "returns an active scope relation" do
        # expect(Song.filter_by_user_settings(user1).class).to_not be_a(Array)
      # end

        
      end
      
      describe "filters by song data" do
        
      end
    
    end
    
    it "returns a list of songs with no albums" do
      songlist = create_list(:song, 6, album: nil)
      songlist2 = create_list(:song, 3, :with_album)
      expect(Song.no_album).to eq(songlist)
    end
     
    
end


