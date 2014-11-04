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

      it "updates artists"
      it "updates artists through names"
      it "updates sources"
      it "updates sources through names"
      it "updates organizations"
      it "updates organizations through names"
      it "creates new songs"
      it "adds events"
      include_examples "can update self-relations", :album
      include_examples "updates dates properly", :album, "release_date"
      include_examples "updates with normal attributes", :album
      
    end
    
  #Scope Tests
    it "reports released records"
    
end


