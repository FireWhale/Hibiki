require 'rails_helper'


describe Album do
  include_examples "global model tests" #Global Tests
  
  describe "Module Tests" do
    it_behaves_like "it has a language field", "name"
    it_behaves_like "it can be solr-searched"
    it_behaves_like "it can be autocompleted"
    it_behaves_like "it has pagination"
    it_behaves_like "it has form_fields"
    it_behaves_like "it has a custom json method"
  end
    
  describe "Association Tests" do
    it_behaves_like "it has images"
    it_behaves_like "it has posts"
    it_behaves_like "it has tags"
    it_behaves_like "it has self-relations"
    it_behaves_like "it has collections"
    
    include_examples "it has a primary relation", Artist, ArtistAlbum
    include_examples "it has a primary relation", Organization, AlbumOrganization
    include_examples "it has a primary relation", Source, AlbumSource
    include_examples "it has_many through", Event, AlbumEvent, :with_album_event
    
    describe "it has a relationship with songs" do   
      it "has many songs" do
        expect(create(:album, :with_songs).songs.first).to be_a Song
        expect(Album.reflect_on_association(:songs).macro).to eq(:has_many)  
      end
      
      it "destroys it's songs when destroyed" do
        album = create(:album, :with_song)
        expect{album.destroy}.to change(Song, :count).by(-1)
      end
      
      it "is valid with songs" do
        album = create(:album)
        list = create_list(:song, 5, album: album)
        expect(album.songs).to match_array(list)
      end
      
      it "is valid without songs" do
        #well the factory doesn't come with songs
        expect(create(:album)).to be_valid
      end
    end
  end
    
  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :status
    include_examples "is invalid without an attribute", :catalog_number
    include_examples "name/reference combinations"
    
    include_examples "is valid with or without an attribute", :altname, "hi"
    include_examples "is valid with or without an attribute", :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :classification, "classification!"
  end
      
  describe "Attribute Tests" do
    include_examples "it has a partial date", :release_date
    it_behaves_like "it has a serialized attribute", :reference
    it_behaves_like "it has a serialized attribute", :namehash
  end
  
  describe "Instance Method Tests" do
    
    describe "returns the right week/month/year" do
      let(:album) {create(:album, release_date: Date.today, release_date_bitmask: 6)}
      
      it "returns the right week" do
        expect(album.week).to eq(Date.today.beginning_of_week(:sunday))
      end
      
      it "takes in a different starting day for the week" do
        expect(album.week("monday")).to eq(Date.today.beginning_of_week(:monday))
      end
      
      it "returns the right month" do
        expect(album.month).to eq(Date.today.beginning_of_month)
      end
      
      it "returns the right year" do
        expect(album.year).to eq(Date.today.beginning_of_year)
      end
      
      it "returns nil if there is no release_date" do
        album_no_date = create(:album, release_date: nil)
        expect(album_no_date.week).to be_nil
        expect(album_no_date.month).to be_nil
        expect(album_no_date.year).to be_nil
      end
      
      # it "handles variable dates from day/week/year" 
      #Thought about it for an hour, and can't see any way these interact.
    end 
    
    
    it "returns the right collection type" do
      album1 = create(:album)
      album2 = create(:album)
      album3 = create(:album)
      album4 = create(:album)
      user = create(:user)
      collection = create(:collection, collected: album1, user: user, relationship: "Collected")
      collection = create(:collection, collected: album2, user: user, relationship: "Ignored")
      collection = create(:collection, collected: album3, user: user, relationship: "Wishlisted")
      expect(album4.collected_category(user)).to eq("")
      expect(album1.collected_category(user)).to eq("Collected")
      expect(album2.collected_category(user)).to eq("Ignored")
      expect(album3.collected_category(user)).to eq("Wishlisted")
      expect(album1.collected_category(nil)).to eq("")
    end
    
    describe "tests for certain self_relations" do
      it "responds to limited_edition?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Limited Edition")
        expect(album.limited_edition?).to be_truthy
        expect(album2.limited_edition?).to be_falsey
      end
      
      it "responds to reprint?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Reprint")
        expect(album.reprint?).to be_truthy
        expect(album2.reprint?).to be_falsey
      end
      
      it "responds to alternate_printing?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Alternate Printing")
        expect(album.alternate_printing?).to be_truthy
        expect(album2.alternate_printing?).to be_falsey
      end
    end
  end
  
  #Class Method Tests    
    describe "has a full update method" do
      include_examples "updates with keys and values"
      include_examples "updates the reference properly" 
      include_examples "can upload an image"
      include_examples "updates namehash properly"

      context "updates artists by id" do
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
          attributes.merge!(:update_artist_albums => {artist_album.id.to_s => ["Performer", "Arranger", "Composer"]})
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
          attributes.merge!(:update_artist_albums => {artist_album.id.to_s => ["Performer", "Arranger", "Composer"], artist_album2.id.to_s => ["Composer", "FeatArranger"]})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(0)
          expect(album.artist_albums.first.category).to eq("7")
          expect(album.artist_albums[1].category).to eq("33")          
        end
        
        it "destroys artist_albums" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          attributes.merge!(:update_artist_albums => {artist_album.id.to_s => []})
          expect{album.full_update_attributes(attributes)}.to change(ArtistAlbum, :count).by(-1)
        end
        
        it "doesn't destroy artists" do
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          attributes.merge!(:update_artist_albums => {artist_album.id.to_s => []})
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(0)          
        end
        
        it "destroy multiple artist_albumss" do 
          album = create(:album)
          attributes = attributes_for(:album)
          artist = create(:artist, name: 'hihi')
          artist2 = create(:artist, name: 'hihooi')
          artist_album = create(:artist_album, album: album, artist: artist, category: 33)
          artist_album2 = create(:artist_album, album: album, artist: artist2, category: 44)
          attributes.merge!(:update_artist_albums => {artist_album.id.to_s => [], artist_album2.id.to_s => []})
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

      include_examples "can update a primary relationship", Organization, AlbumOrganization
      
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
        
        it "ignores certain artists that are included in the 'IgnoreArtist' Constant " do
          album = create(:album)
          attributes = attributes_for(:album)
          ignored_artists = Album::IgnoredArtistNames.sample(2)
          attributes.merge!(:new_artist_names => ['Hey', "ho"] + ignored_artists)
          attributes.merge!(:new_artist_categories_scraped => ['Performer', 'Composer', 'New Artist', 'Performer', 'New Artist', 'Composer', 'New Artist', 'Composer', 'New Artist'])
          expect{album.full_update_attributes(attributes)}.to change(Artist, :count).by(2)               
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
      
      include_examples "can update self-relations"
      include_examples "updates dates properly", "release_date"
      include_examples "updates with normal attributes"
      
    end
    
  #Scope Tests
  describe "Scoping" do 
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by tag"    
    it_behaves_like "filters by date range", "release_date"
    it_behaves_like "filters by self relation categories"
    it_behaves_like "filters by collection"
        
    describe "filters by AOS" do
      let(:album1) {create(:album)} 
      let(:album2) {create(:album)}
      let(:album3) {create(:album)}
      let(:album4) {create(:album)}
      
      ["artist", "source", "organization"].each do |model|
        describe "by #{model}" do
          join_table_symbol = (model == "artist" ? :artist_album : "album_#{model}".to_sym)
          let(:record1) {create(model.to_sym)} #album1, album2
          let(:record2) {create(model.to_sym)} #album1
          let(:record3) {create(model.to_sym)} #album2
          let(:record4) {create(model.to_sym)} #album3
          let(:record5) {create(model.to_sym)} 
          before(:each) do 
            create(join_table_symbol, album: album1, model.to_sym => record1) 
            create(join_table_symbol, album: album1, model.to_sym => record2) 
            create(join_table_symbol, album: album2, model.to_sym => record1) 
            create(join_table_symbol, album: album2, model.to_sym => record3)  
            create(join_table_symbol, album: album3, model.to_sym => record4)               
          end
          
          it "filters by #{model}_id" do
            expect(Album.send("with_#{model}",record1.id)).to match_array([album1,album2])
          end
          
          it "matches on several ids" do
            expect(Album.send("with_#{model}",[record2.id, record4.id])).to match_array([album1,album3])
          end

          it "does not duplicate an album if it matches several times" do
            expect(Album.send("with_#{model}",[record2.id, record1.id])).to match_array([album1,album2])            
          end
          
          it "can match on nothing" do
            expect(Album.send("with_#{model}",record5.id)).to match_array([])            
          end
                    
          it "returns all records if nil is passed in" do
            expect(Album.send("with_#{model}",nil)).to match_array([album1,album2,album3,album4])                        
          end
          
          it "returns an active record relation" do
            expect(Album.send("with_#{model}",record5.id).class).to_not be_a(Array)               
          end
        end
        
      end
      
      describe "filters by artists, sources, and organizations" do
        let(:artist1) {create(:artist)} #album1, #album2
        let(:artist2) {create(:artist)} #album3
        let(:organization1) {create(:organization)} #album4
        let(:organization2) {create(:organization)} #album 2
        let(:organization3) {create(:organization)}
        let(:source1) {create(:source)} #album2
        let(:source2) {create(:source)} #album3, album4
        before(:each) do
          create(:artist_album, album: album1, artist: artist1)
          create(:artist_album, album: album2, artist: artist1)
          create(:artist_album, album: album3, artist: artist2)
          create(:album_organization, album: album2, organization: organization2)
          create(:album_organization, album: album4, organization: organization1)
          create(:album_source, album: album2, source: source1)
          create(:album_source, album: album3, source: source2)
          create(:album_source, album: album4, source: source2)
          
        end
        
        it "filters by artists, sources, and organizations" do
          expect(Album.with_artist_organization_source(artist1.id, organization1.id, source1.id)).to match_array([album1,album2,album4])
        end
        
        it "matches on several ids" do
          expect(Album.with_artist_organization_source(artist2.id, [organization1.id, organization2.id], source1.id)).to match_array([album3,album2,album4])
        end
        
        it "does not duplicate album results" do
          expect(Album.with_artist_organization_source(artist1.id, organization2.id, source1.id)).to match_array([album1,album2])          
        end
        
        it "can match on nothing" do
          expect(Album.with_artist_organization_source(nil, organization3.id, nil)).to match_array([])                    
        end
        
        it "does not return all if one id is nil" do
          expect(Album.with_artist_organization_source(artist2.id, nil, [source1.id, source2.id])).to match_array([album2,album4,album3])          
        end
        
        it "returns all if nil is passed into all 3 arguments" do
          expect(Album.with_artist_organization_source(nil, nil, nil)).to match_array([album1,album2,album3,album4])                    
        end
        
        it "returns an active record relation" do
          expect(Album.with_artist_organization_source(artist2.id, nil, nil).class).to_not be_a(Array)                  
        end
      end
      
    end
    
    describe "filters by user_settings" do
      let(:user1) {create :user}
      let(:user2) {create :user}
      let(:album1) {create :album} #ignored album from user 1
      let(:album2) {create :album} #ignored album from user 2 
      let(:album3) {create :album} #limited edition of album 1
      let(:album4) {create :album} #reprint of album 2
      let(:album5) {create :album} #ignored album from user 1
      let(:album6) {create :album} #Watched album from user 1
      let(:album7) {create :album} #no relations, should always return
      before(:each) do
        create(:collection, user: user1, collected: album1, relationship: "Ignored")
        create(:collection, user: user2, collected: album2, relationship: "Ignored")
        create(:collection, user: user1, collected: album5, relationship: "Ignored")
        create(:collection, user: user1, collected: album6, relationship: "Wishlisted")
        create(:related_albums, album1: album3, album2: album1, category: "Limited Edition")
        create(:related_albums, album1: album4, album2: album2, category: "Reprint")
      end
      
      #1 is show LE
      #4 is show ignored
      #64 is show reprints
      
      it "filters out ignored albums" do
        user1.update_attribute("display_bitmask", 65) 
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album3,album4,album6,album7])
      end
      
      it "filters out reprints" do
        user1.update_attribute("display_bitmask", 5) 
        expect(Album.filter_by_user_settings(user1)).to match_array([album1,album2,album3,album5,album6,album7])        
      end
      
      it "filters out limited editions" do
        user1.update_attribute("display_bitmask", 68) 
        expect(Album.filter_by_user_settings(user1)).to match_array([album1,album2,album4,album5,album6,album7])        
      end
      
      it "filters an album out if it matches on LE but not reprint" do
        user1.update_attribute("display_bitmask", 64) 
        album8 = create(:album)
        create(:related_albums, album1: album8, album2: album2, category: "Reprint")
        create(:related_albums, album1: album4, album2: album1, category: "Limited Edition")
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album6,album7,album8])        
      end
      
      it "filters an album out if it matches on ignored but not LE" do
        user1.update_attribute("display_bitmask", 1)
        create(:collection, user: user1, collected: album3, relationship: "Ignored")
        create(:related_albums, album1: album6, album2: album1, category: "Limited Edition")
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album6,album7])        
      end
      
      it "returns all if nil is passed in" do
        expect(Album.filter_by_user_settings(nil)).to match_array([album1,album2,album3,album4,album5,album6,album7])                
      end
      
      it "returns an active scope relation" do
        expect(Album.filter_by_user_settings(user1).class).to_not be_a(Array)     
      end
    end
  end
    
end


