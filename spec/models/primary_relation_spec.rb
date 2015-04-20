require 'rails_helper'

shared_examples "it has a category" do |attribute, category|
  #Validation
    it_behaves_like "is invalid without an attribute", attribute
    it_behaves_like "is invalid without an attribute in a category", attribute, category
        
end

shared_examples "it has an artist bitmask" do |model_symbol|
  #Validation
    it "is invalid without a category (artist bitmask)" do
      expect(build(model_symbol, category: 0)).to_not be_valid
      expect(build(model_symbol, category: nil)).to_not be_valid
    end
    
    it "is invalid with a category outside the bitmask range" do
      expect(build(model_symbol, category: 9999999)).to_not be_valid      
    end  
    
    it "is valid with a category" do
      expect(build(model_symbol, category: 100)).to be_valid
    end
end

describe AlbumOrganization do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Album, Organization
    it_behaves_like "it has a category", :category, AlbumOrganization::Categories
end

describe AlbumSource do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Album, Source
end

describe ArtistAlbum do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Artist, Album
    it_behaves_like "it has an artist bitmask", :artist_album
end

describe ArtistOrganization do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Artist, Organization
    it_behaves_like "it has a category", :category, ArtistOrganization::Categories
end  

describe ArtistSong do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Artist, Song
    it_behaves_like "it has an artist bitmask", :artist_song
  
  #Callbacks
    it "adds the artist to the album as well" do
      album = create(:album)
      song = create(:song, album: album)
      artist = create(:artist)
      song_source = create(:artist_song, song: song, artist: artist)
      expect(album.artists).to match_array([artist])
    end
    
    it "does not add the artist if there is no album" do
      song = create(:song)
      artist = create(:artist)
      expect{create(:artist_song, song: song, artist: artist)}.to change(ArtistAlbum, :count).by(0)
    end
    
end
    
describe SongSource do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Song, Source
    include_examples "is valid with or without an attribute", :classification, "OP"
    include_examples "is valid with or without an attribute", :op_ed_number, "5"
    include_examples "is valid with or without an attribute", :ep_numbers, "23-49"
    it_behaves_like "is invalid without an attribute in a category", :classification, SongSource::Relationship
    
  #Callbacks    
    it "adds the source to the album as well" do
      album = create(:album)
      song = create(:song, album: album)
      source = create(:source)
      song_source = create(:song_source, song: song, source: source)
      expect(album.sources).to match_array([source])
    end

    it "does not add the source if there is no album" do
      song = create(:song)
      source = create(:source)
      expect{create(:song_source, song: song, source: source)}.to change(AlbumSource, :count).by(0)
    end
    
  #More Validation
    include_examples "is valid with or without an attribute", :op_ed_number, "some op number"
    include_examples "is valid with or without an attribute", :ep_numbers, "some episode numbers"

end

describe SourceOrganization do
  include_examples "global model tests" #Global Tests
  
  #Shared Examples
    it_behaves_like "a join table", Source, Organization
    it_behaves_like "it has a category", :category, SourceOrganization::Categories
end
