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
      
    it "belongs to an album" do
      expect(create(:song, :with_album).album).to be_a Album
      expect(Song.reflect_on_association(:album).macro).to eq(:belongs_to)
    end
    
    it "does not destroy the album when destroyed" do
      song = create(:song, :with_album)
      expect{song.destroy}.to change(Album, :count).by(0)
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

    include_examples "is valid with or without an attribute", :song, :altname, "hi"
    include_examples "is valid with or without an attribute", :song, :track_number, "hi"
    include_examples "is valid with or without an attribute", :song, :disc_number, "hi"
    include_examples "is valid with or without an attribute", :song, :length, 12323
    include_examples "is valid with or without an attribute", :song, :lyrics, "DANCE"
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
    
    context "hass a full update method" do
      include_examples "updates with keys and values", :song
      include_examples "updates the reference properly", :song
      include_examples "can upload an image", :song
      it "updates artists"
      it "updates it's album's artists"
      it "updates sources"
      it "updates it's album's sources"
      include_examples "can update self-relations", :song
      it "formats the length aka duration into an integer"
      it "formats tracknumbers into a disc_number and track_number"
      it "adds a discnumber if there is no disc number"
      include_examples "updates dates properly", :song, "release_date"
      include_examples "updates with normal attributes", :song
     
    end       
    
  #Scope Tests
    it "returns a list of songs with no albums" do
      songlist = create_list(:song, 6, album: nil)
      songlist2 = create_list(:song, 3, :with_album)
      expect(Song.no_album).to eq(songlist)
    end
end


