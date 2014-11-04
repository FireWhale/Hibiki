require 'rails_helper'

shared_examples "it has a category" do |model_symbol, attribute, category|
  #Validation
    it_behaves_like "is invalid without an attribute", model_symbol, attribute.to_sym
    it_behaves_like "is invalid without an attribute in a category", model_symbol, attribute.to_sym, category
        
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
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:album_organization)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :album_organization, "album", "organization", AlbumOrganization
    it_behaves_like "it has a category", :album_organization, "category", AlbumOrganization::Categories
end

describe AlbumSource do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:album_source)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :album_source, "album", "source", AlbumSource
end

describe ArtistAlbum do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_album)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :artist_album, "artist", "album", ArtistAlbum
    it_behaves_like "it has an artist bitmask", :artist_album
end

describe ArtistOrganization do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_organization)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :artist_organization, "artist", "organization", ArtistOrganization
    it_behaves_like "it has a category", :artist_organization, "category", ArtistOrganization::Categories
end  

describe ArtistSong do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_song)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :artist_song, "artist", "song", ArtistSong
    it_behaves_like "it has an artist bitmask", :artist_song
    
end
    
describe SongSource do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:song_source)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :song_source, "song", "source", SongSource
    it_behaves_like "it has a category", :song_source, "classification", SongSource::Relationship
    
  #More Validation
    include_examples "is valid with or without an attribute", :song_source, :op_ed_number, "some op number"
    include_examples "is valid with or without an attribute", :song_source, :ep_numbers, "some episode numbers"

end

describe SourceOrganization do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:source_organization)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", :source_organization, "source", "organization", SourceOrganization
    it_behaves_like "it has a category", :source_organization, "category", SourceOrganization::Categories
end
