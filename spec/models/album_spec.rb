require 'rails_helper'

describe Album do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:album)
      expect(instance).to be_valid
    end

  #Shared Examples
    it_behaves_like "it has images", :album, Album
    it_behaves_like "it has tags", :album, Album
    it_behaves_like "it has posts", :album, Album
    it_behaves_like "it can be searched", :album, Album
    it_behaves_like "it can be autocompleted", :album
    it_behaves_like "it has pagination", "artist"  
  
  #Association Tests
    it_behaves_like "it has self-relations", :album, "album", RelatedAlbums
    it_behaves_like "it has a primary relation", :album, "artist", ArtistAlbum, :artist_album
    it_behaves_like "it has a primary relation", :album, "organization", AlbumOrganization, :album_organization
    it_behaves_like "it has a primary relation", :album, "source", AlbumSource, :album_source
         
    it "has many songs" do
      expect(create(:album, :with_songs).songs.first).to be_a Song
      expect(Album.reflect_on_association(:songs).macro).to eq(:has_many)  
    end
    
    it "destroys it's songs when destroyed" do
      album = create(:album, :with_song)
      expect{album.destroy}.to change(Song, :count).by(-1)
    end
    
      it "has many collections" do
        expect(create(:album, :with_collection).collections.first).to be_a Collection
        expect(Album.reflect_on_association(:collections).macro).to eq(:has_many)
      end
      
      it "has many collectors" do
        expect(create(:album, :with_collection).collectors.first).to be_a User
        expect(Album.reflect_on_association(:collectors).macro).to eq(:has_many)
      end
      
      it "destroys collections when destroyed" do
        record = create(:album, :with_collection)
        expect{record.destroy}.to change(Collection, :count).by(-1)
      end
      
      it "does not destroy users when destroyed" do
        record = create(:album, :with_collection)
        expect{record.destroy}.to change(User, :count).by(0)
      end    
    
    it_behaves_like "it has_many", :album, "event", "album_event", AlbumEvent, :with_album_event
    
  #Validation Tests
    it "is valid with songs" do
      album = create(:album)
      list = create_list(:song, 5, album: album)
      expect(album.songs).to match_array(list)
    end
    
    it "is valid without songs" do
      #well the factory doesn't come with songs
      expect(create(:album)).to be_valid
    end

    context "Collectors Validations" do
      it "is invalid without a real user" do
        record = create(:album)
        expect(build(:collection, :album => record, :user_id => 999999)).to_not be_valid
      end
          
      it "is valid with multiple collections" do
        record = create(:album)
        number = Array(3..10).sample
        list = create_list(:collection, number, :album => record)
        expect(record.collections).to match_array(list)
        expect(record).to be_valid
      end
      
      it "is valid with multiple collectors" do
        record = create(:album)
        number = Array(3..10).sample
        list = create_list(:collection, number, :album => record)
        expect(record.collectors.count).to eq(number)
        expect(record).to be_valid
      end  
    end
        
    include_examples "is invalid without an attribute", :album, :name
    include_examples "is invalid without an attribute", :album, :status
    include_examples "is invalid without an attribute", :album, :catalog_number
    include_examples "name/reference combinations", :album
    
    include_examples "is valid with or without an attribute", :album, :altname, "hi"
    include_examples "is valid with or without an attribute", :album, :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :album, :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :album, :classification, "classification!"
    
    it_behaves_like "it has a partial date", :album, :release_date
      
  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :album, :reference
    it_behaves_like "it has a serialized attribute", :album, :namehash
    
  #Instance Method Tests
    it "returns the right day/week/year" 
    
    it "handles variable dates from day/week/year"
    
    context "Collection Methods" do
      before(:each) do 
        @album1 = create(:album)
        @album2 = create(:album)
        @album3 = create(:album)
        @user = create(:user)
        collection = create(:collection, album: @album1, user: @user, relationship: "Collected")
        collection = create(:collection, album: @album2, user: @user, relationship: "Ignored")
        collection = create(:collection, album: @album3, user: @user, relationship: "Wishlist")
      end
      
      it "returns collection" do
        expect(@album1.collected?(@user)).to be true
        expect(@album2.collected?(@user)).to be false
      end
      
      it "returns ignored" do
        expect(@album2.ignored?(@user)).to be true
        expect(@album3.ignored?(@user)).to be false
      end
            
      it "returns wishlist" do
        expect(@album3.wishlist?(@user)).to be true
        expect(@album2.wishlist?(@user)).to be false
      end
    
      it "returns the right collection type" do
        album = create(:album)
        expect(album.collected_category(@user)).to eq("")
        expect(@album1.collected_category(@user)).to eq("Collected")
        expect(@album2.collected_category(@user)).to eq("Ignored")
        expect(@album3.collected_category(@user)).to eq("Wishlist")
      end
    end
      
  #Class Method Tests    
    context "has a full update method" do
      include_examples "updates with keys and values", :album
      include_examples "updates the reference properly", :album   
      include_examples "can upload an image", :album
      include_examples "updates namehash properly", :album

      context "updates artists" do
        it "creates an album_artist" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "New Artist"])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(1)
          expect(album.artists.first.name).to eq("hihi")
          expect(album.artist_albums.first.category).to eq("4")
        end
        
        it "handles multiple categories" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_ids => [artist.id.to_s], :new_artist_categories => ["Performer", "Composer", "New Artist"])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(1)
          expect(album.artists.first.name).to eq("hihi")
          expect(album.artist_albums.first.category).to eq("5")
        end
        
        it "can create multiple album_artists" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist2 =create(:artist, name: 'hoho')
          attributes.merge!(:new_artist_ids => [artist.id.to_s, artist2.id.to_s], :new_artist_categories => ["Performer", "Composer", "New Artist", "Performer", "New Artist" ])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(2)
          expect(album.artists.first.name).to eq("hihi")
          expect(album.artist_albums.first.category).to eq("5")
          expect(album.artists[1].name).to eq("hoho")
          expect(album.artist_albums[1].category).to eq("4")
        end
        
        it "does not create artist_albums if it doesn't exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_artist_ids => ["999999"], :new_artist_categories => ["Performer", "Composer", "New Artist"])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)
        end
        
        it "updates artist_albums" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          attributes.merge!(:update_album_artists => {artist_album.id.to_s => ["Performer", "Arranger", "Composer"]})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)
          expect(album.artist_albums.first.category).to eq("7")
        end
        
        it "updates multiple artist_albums" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist2 = create(:artist, name: 'hihooi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          artist_album2 = create(:artist_album, album: album, artist: artist2, category: 44)
          attributes.merge!(:update_album_artists => {artist_album.id.to_s => ["Performer", "Arranger", "Composer"], artist_album2.id.to_s => ["Composer", "FeatArranger"]})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)
          expect(album.artist_albums.first.category).to eq("7")
          expect(album.artist_albums[1].category).to eq("33")          
        end
        
        it "destroys artist_albums" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          attributes.merge!(:update_album_artists => {artist_album.id.to_s => []})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(-1)
        end
        
        it "doesn't destroy artists" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          attributes.merge!(:update_album_artists => {artist_album.id.to_s => []})
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(0)          
        end
        
        it "destroy multiple artist_albumss" do 
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist2 = create(:artist, name: 'hihooi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          artist_album2 = create(:artist_album, album: album, artist: artist2, category: 44)
          attributes.merge!(:update_album_artists => {artist_album.id.to_s => [], artist_album2.id.to_s => []})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(-2)
        end
        
      end
      
      context "updates sources by id" do
        it "creates an album_source" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_ids => [source.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(1)
          expect(album.sources.first.name).to eq("hihi")
        end
        
        it "creates multiple album_sources" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          source2 = create(:source, name: 'hoho')
          attributes.merge!(:new_source_ids => [source.id.to_s, source2.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(2)
          expect(album.sources.map(&:name)).to eq(["hihi", 'hoho'])
        end
        
        it "does not create a source if it doesn't exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_ids => ["999999"])
          expect{album.full_update_attributes(attributes)}.to change(Source, :count).by(0)
        end
        
        it "does not create an album_source if the source doesn't exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_ids => ["999999"])
          expect{album.full_update_attributes(attributes)}.to change(Source, :count).by(0)
        end
        
        it "destroys album_sources" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          album_source = create(:album_source, album: album, source: source)
          attributes.merge!(:remove_album_sources => [album_source.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(-1)
        end
     
        it "doesn't destroy sources" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          album_source = create(:album_source, album: album, source: source)
          attributes.merge!(:remove_album_sources => [album_source.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(Source, :count).by(0)
        end
        
        it "destroys many album_sources" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          source2 = create(:source, name: 'hoho')
          album_source = create(:album_source, album: album, source: source)
          album_source2 = create(:album_source, album: album, source: source2)
          attributes.merge!(:remove_album_sources => [album_source.id.to_s, album_source2.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(-2)
        end
      end
      
      
      context "updates artists through names" do
        it "creates an album_artist" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_names => ['hihi'])
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(1)
          expect(album.artists.first.name).to eq("hihi")
        end
       
        it "creates multiple album_artists" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_names => ['hihi', 'wallwall'])
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'New Artist', 'Performer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(2)
          expect(album.reload.artists.map(&:name)).to match_array(["hihi", "wallwall"])
          expect(album.artist_albums.first.category).to eq("4")
        end
        
        it "does not create an artist if one exists" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          attributes.merge!(:new_artist_names => ['hihi'])
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(0)
          expect(album.artists.first.name).to eq("hihi")
        end
        
        it "creates an artist if one does not exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_artist_names => ['hihi'])
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(1)
          expect(album.artists.first.name).to eq("hihi")          
        end        
        
        it "creates an artist with multiple categories" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_artist_names => ['hihi'])
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'Composer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(1)
          expect(album.artists.first.name).to eq("hihi")              
          expect(album.artist_albums.first.category).to eq("5")
        end
        
      end
      
      context "updates sources through names" do
        it "creates a album_source" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_names => ['hihi'])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(1)
          expect(album.sources.first.name).to eq("hihi")
        end
        
        it "creates multiple album_sources" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_names => ['hihi', 'wallwall'])
          expect{album.full_update_attributes(attributes)}.to change(AlbumSource, :count).by(2)
          expect(album.reload.sources.map(&:name)).to match_array(["hihi", "wallwall"])
        end
        
        it "does not create a source if one exists" do
          album = create(:album)
          attributes = attributes_for(:album)
          source = create(:source, name: 'hihi')
          attributes.merge!(:new_source_names => ['hihi'])
          expect{album.full_update_attributes(attributes)}.to change(Source, :count).by(0)
          expect(album.sources.first.name).to eq("hihi")
        end
        
        it "creates a source if one does not exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_source_names => ['hihi'])
          expect{album.full_update_attributes(attributes)}.to change(Source, :count).by(1)
          expect(album.sources.first.name).to eq("hihi")          
        end
      end
      include_examples "can update a primary relationship", :album, :organization, AlbumOrganization, "album_organization"

      context "adds organizations through names" do
        it "creates an album_organization" do       
          album = create(:album)
          attributes = attributes_for(:album)
          organization = create(:organization, name: 'hihi')
          attributes.merge!(:new_organization_names => ['hihi'], :new_organization_categories_scraped => ['Publisher'])
          expect{album.full_update_attributes(attributes)}.to change(AlbumOrganization, :count).by(1)
          expect(album.organizations.first.name).to eq("hihi")
          expect(album.album_organizations.first.category).to eq("Publisher")   
        end
        
        
        it "cretes multiple album_organizations" do
          album = create(:album)
          attributes = attributes_for(:album)
          organization = create(:organization, name: 'hihi')
          attributes.merge!(:new_organization_names => ['hihi', 'numba2', 'three'], :new_organization_categories_scraped => ['Publisher','Distributor','Publisher'])
          expect{album.full_update_attributes(attributes)}.to change(AlbumOrganization, :count).by(3)
          
        end
 
        it "does not create a new organization if it exists" do
          album = create(:album)
          attributes = attributes_for(:album)
          organization = create(:organization, name: 'hihi')
          attributes.merge!(:new_organization_names => ['hihi'], :new_organization_categories_scraped => ['Publisher'])
          expect{album.full_update_attributes(attributes)}.to change(Organization, :count).by(0)
          
        end
        
        it "creates a new organization if one does not exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_organization_names => ['willow'], :new_organization_categories_scraped => ['Publisher'])
          expect{album.full_update_attributes(attributes)}.to change(Organization, :count).by(1)
          expect(album.organizations.first.name).to eq("willow")
          expect(album.album_organizations.first.category).to eq("Publisher")   
        end
      end
      
      context "it full updates songs" do
        it "creates a new song" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_songs => {'track_numbers' => ["1"], 'names' => ["hello"]})
          expect{album.full_update_attributes(attributes)}.to change(Song, :count).by(1)
          expect(album.songs.first.name).to eq("hello")
          expect(album.songs.first.track_number).to eq("01")
        end
        
        it "creates multiple songs" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_songs => {'track_numbers' => ["1", "2"], 'names' => ["hello", "song 2"]})
          expect{album.full_update_attributes(attributes)}.to change(Song, :count).by(2)
          expect(album.songs.first.name).to eq("hello")
          expect(album.songs.first.track_number).to eq("01")
          expect(album.songs[1].name).to eq("song 2")
          expect(album.songs[1].track_number).to eq("02")
        end
        
        it "creates new songs with lengths and namehashes" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_songs => {'track_numbers' => ["1", "2"], 'names' => ["hello", "song 2"],
                                           'namehashes' => [{English: "hello", Romaji: "34234"}, {English: "song 3"}],
                                           'lengths' => [50, 30]})
          expect{album.full_update_attributes(attributes)}.to change(Song, :count).by(2)
          expect(album.songs.first.name).to eq("hello")
          expect(album.songs.first.track_number).to eq("01")
          expect(album.songs.first.namehash[:English]).to eq("hello")
          expect(album.songs.first.length).to eq(50)
          expect(album.songs[1].name).to eq("song 2")
          expect(album.songs[1].track_number).to eq("02")     
          expect(album.songs[1].namehash[:English]).to eq("song 3")  
          expect(album.songs[1].length).to eq(30)   
        end
        
        it "does not work if tracknumbers is empty" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_songs => {'names' => ["hello"]})
          expect{album.full_update_attributes(attributes)}.to change(Song, :count).by(0)
        end
        
        it "does not work if names are empty" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_songs => {'track_numbers' => ["tracky"]})
          expect{album.full_update_attributes(attributes)}.to change(Song, :count).by(0)
        end
        
      end


      context "it full updates events" do 
        it "adds an event" do
          album = create(:album)
          attributes = attributes_for(:album)
          event = create(:event, shorthand: "shorty")
          attributes.merge!(:new_event_shorthands => ["shorty"])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(1)
          expect(album.events.first).to eq(event)
        end
        
        it "creates events that do not exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          attributes.merge!(:new_event_shorthands => ["shorty"])
          expect{album.full_update_attributes(attributes)}.to change(Event, :count).by(1)
          expect(album.events.first.shorthand).to eq("shorty")
        end
        
        it "deletes an albumevent" do
          album = create(:album)
          event = create(:event)
          album_event = create(:album_event, event: event, album: album)
          attributes = attributes_for(:album)
          attributes.merge!(:remove_events => [event.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(-1)
        end
        
        it "does not delete the event" do
          album = create(:album)
          event = create(:event)
          album_event = create(:album_event, event: event, album: album)
          attributes = attributes_for(:album)
          attributes.merge!(:remove_events => [event.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(Event, :count).by(0)
        end
        
        it "does not delete an albumevent that does not exist" do
          album = create(:album)
          event = create(:event)
          album_event = create(:album_event, album: album)
          attributes = attributes_for(:album)
          attributes.merge!(:remove_events => [event.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(0)
        end
        
        it "adds multiple events" do
          album = create(:album)
          attributes = attributes_for(:album)
          event = create(:event, shorthand: "shorty")
          event2 = create(:event, shorthand: "tally")
          attributes.merge!(:new_event_shorthands => ["shorty", "tally"])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(2)
          expect(album.events).to match_array([event, event2])          
        end
        
        it "adds multiple events that may or may not exist" do
          album = create(:album)
          attributes = attributes_for(:album)
          event = create(:event, shorthand: "shorty")
          event2 = create(:event, shorthand: "tally")
          attributes.merge!(:new_event_shorthands => ["shorty", "tally", "holly"])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(3)
          expect(album.events.count).to eq(3)   
          expect(Event.find_by_shorthand("holly")).to be_a Event           
        end
        
        it "removes multiple events" do
          album = create(:album)
          event = create(:event)
          event2 = create(:event)
          album_event = create(:album_event, event: event, album: album)
          album_event2 = create(:album_event, event: event2, album: album)
          attributes = attributes_for(:album)
          attributes.merge!(:remove_events => [event.id.to_s, event2.id.to_s])
          expect{album.full_update_attributes(attributes)}.to change(AlbumEvent, :count).by(-2)
        end
      end
      include_examples "can update self-relations", :album
      include_examples "updates dates properly", :album, "release_date"
      include_examples "updates with normal attributes", :album
      
    end
    
  #Scope Tests
    it_behaves_like "it reports released records", :album
    
end


