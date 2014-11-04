require 'rails_helper'

describe Artist do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist)
      expect(instance).to be_valid
    end
  
  #Shared Examples
    it_behaves_like "it has images", :artist, Artist
    it_behaves_like "it has tags", :artist, Artist
    it_behaves_like "it has posts", :artist, Artist
    it_behaves_like "it has watchlists", :artist, Artist
    it_behaves_like "it can be searched", :artist, Artist
    it_behaves_like "it can be autocompleted", :artist
    it_behaves_like "it has pagination", "artist"

  #Association Tests
    it_behaves_like "it has self-relations", :artist, "artist", RelatedArtists
    it_behaves_like "it has a primary relation", :artist, "album", ArtistAlbum, :artist_album
    it_behaves_like "it has a primary relation", :artist, "organization", ArtistOrganization, :artist_organization
    it_behaves_like "it has a primary relation", :artist, "song", ArtistSong, :artist_song
        
  #Validation Tests
    include_examples "is invalid without an attribute", :artist, :name
    include_examples "is invalid without an attribute", :artist, :status
    include_examples "name/reference combinations", :artist

    include_examples "is invalid without an attribute in a category", :artist, :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :artist, :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :artist, :activity, Artist::Activity, "Artist::Activity"
    include_examples "is invalid without an attribute in a category", :artist, :category, Artist::Categories, "Artist::Categories"

    include_examples "redirects to a new record when db_status is hidden", :artist, "something"
    
    include_examples "is valid with or without an attribute", :artist, :altname, "hi"
    include_examples "is valid with or without an attribute", :artist, :db_status, "Complete"
    include_examples "is valid with or without an attribute", :artist, :activity, Artist::Activity.sample
    include_examples "is valid with or without an attribute", :artist, :category, Artist::Categories.sample
    include_examples "is valid with or without an attribute", :artist, :info, "this is sum info"
    include_examples "is valid with or without an attribute", :artist, :private_info, "this is sum private_info"
    include_examples "is valid with or without an attribute", :artist, :synopsis, "this is a short description!"
    include_examples "is valid with or without an attribute", :artist, :gender, "male I think"
    include_examples "is valid with or without an attribute", :artist, :blood_type, "b+!"
    include_examples "is valid with or without an attribute", :artist, :birth_place, "maybe okinawa?"
    include_examples "is valid with or without an attribute", :artist, :popularity, 3
    
    it_behaves_like "it has a partial date", :artist, :birth_date
    it_behaves_like "it has a partial date", :artist, :debut_date
    
  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :artist, :reference
    it_behaves_like "it has a serialized attribute", :artist, :namehash
       
  #Instance Method Tests
    it "responds to get_bitmask" do
      expect(Artist).to respond_to(:get_bitmask)
    end
    
    it "returns a bitmask that is within the right number range" do
      number = Array(1..Artist::Credits.count).sample
      categories = Artist::Credits.sample(number)
      expect(Artist.get_bitmask(categories)).to be < 512
    end
    
    it "accepts a single credit in get_bitmask" do
      expect(Artist.get_bitmask("Performer")).to eq(4)
    end
    
    it "returns the expected bitmask from a list of categories" do
      expect(Artist.get_bitmask(["Performer", "FeatArranger"])).to eq(36)
    end
    
    it "responds to get_credits" do
      expect(Artist).to respond_to(:get_credits)
    end
    
    it "returns a list of categories that matches the bitmask" do
      bitmask = 21
      expect(Artist.get_credits(bitmask)).to match_array(["Performer", "FeatComposer", "Composer"])
    end
    
    it "is reversible with get_bitmask and get_credits" do
      array = Artist::Credits.shuffle[0..4]
      expect(Artist.get_credits(Artist.get_bitmask(array))).to match_array(array)
    end
    
    it "is reversible with get_bitmask and get_credits 2" do
      bitmask = Array(1..(2**Artist::Credits.count - 1)).sample
      expect(Artist.get_bitmask(Artist.get_credits(bitmask))).to eq(bitmask)
    end    
    
  #Class Method Tests    
    context "hass a full update method" do
      include_examples "updates with keys and values", :artist
      include_examples "updates the reference properly", :artist     
      include_examples "can upload an image", :artist
      include_examples "can update a primary relationship", :artist, :organization, ArtistOrganization, "artist_organization"
      include_examples "can update self-relations", :artist
      include_examples "updates dates properly", :artist, "birth_date"
      include_examples "updates dates properly", :artist, "debut_date"
      include_examples "updates with normal attributes", :artist
      
    end       
    
  #Scope Tests
    it "reports released records"
    
end


