require 'rails_helper'

shared_examples "a join table" do |model, model_symbol, model_1, model_2|
  #Associations
    it "has a #{model_1}" do
      expect(create(model_symbol).send(model_1)).to be_a model_1.capitalize.constantize
      expect(model.reflect_on_association(model_1.to_sym).macro).to eq(:belongs_to)
    end
    
    it "has a #{model_2}" do
      expect(create(model_symbol).send(model_2)).to be_a model_2.capitalize.constantize
      expect(model.reflect_on_association(model_2.to_sym).macro).to eq(:belongs_to)      
    end
  
  #Validation
    it "is valid with a #{model_1} and a #{model_2}" do
      expect(build(model_symbol)).to be_valid
    end
    
    it "is invalid without a #{model_1}" do
      expect(build(model_symbol, model_1.to_sym => nil)).to_not be_valid
    end
    
    it "is invalid without a real #{model_1}" do
      expect(build(model_symbol, (model_1 + "_id").to_sym => 999999999)).to_not be_valid
    end

    it "is invalid without a #{model_2}" do
      expect(build(model_symbol, model_2.to_sym => nil)).to_not be_valid
    end
    
    it "is invalid without a real #{model_2}" do
      expect(build(model_symbol, (model_2 + "_id").to_sym => 999999999)).to_not be_valid
    end
        
    it "should have a unique #{model_1}/#{model_2} combination" do
      @model1 = create(model_1.to_sym)
      @model2 = create(model_2.to_sym)
      expect(create(model_symbol, model_1.to_sym => @model1, model_2.to_sym => @model2)).to be_valid
      expect(build(model_symbol, model_1.to_sym => @model1, model_2.to_sym => @model2)).to be_valid
    end
end

shared_examples "it has a category" do |model_symbol, attribute|
  #Validation
    it "is valid with a #{attribute}" do
      expect(build(model_symbol)).to be_valid
    end
    
    it "is invalid without a #{attribute}" do
      expect(build(model_symbol, attribute.to_sym => "")).to_not be_valid
      expect(build(model_symbol, attribute.to_sym => nil)).to_not be_valid
    end
    
    it "is invalid with a #{attribute} not in the #{attribute} list" do
      expect(build(model_symbol, attribute.to_sym => "hihi")).to_not be_valid      
    end
  
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
    
    it "is valid with a category}" do
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
    it_behaves_like "a join table", AlbumOrganization, :album_organization, "album", "organization"
    it_behaves_like "it has a category", :album_organization, "category"
end

describe AlbumSource do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:album_source)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", AlbumSource, :album_source, "album", "source"   
end

describe ArtistAlbum do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_album)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", ArtistAlbum, :artist_album, "artist", "album"
    it_behaves_like "it has an artist bitmask", :artist_album
end

describe ArtistOrganization do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_organization)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", ArtistOrganization, :artist_organization, "artist", "organization"
    it_behaves_like "it has a category", :artist_organization, "category"
end  

describe ArtistSong do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:artist_song)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", ArtistSong, :artist_song, "artist", "song"
    it_behaves_like "it has an artist bitmask", :artist_song
    
end
    
describe SongSource do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:song_source)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", SongSource, :song_source, "song", "source"
    it_behaves_like "it has a category", :song_source, "classification"  
    
  #More Validation
    it "is valid without an op_ed_number" do
      expect(build(:song_source, op_ed_number: "")).to be_valid
      expect(build(:song_source, op_ed_number: nil)).to be_valid
    end
    
    it "is valid without an ep_numbers" do
      expect(build(:song_source, ep_numbers: "")).to be_valid
      expect(build(:song_source, ep_numbers: nil)).to be_valid
    end
end

describe SourceOrganization do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:source_organization)
      expect(instance).to be_valid
    end
  #Shared Examples
    it_behaves_like "a join table", SourceOrganization, :source_organization, "source", "organization"
    it_behaves_like "it has a category", :source_organization, "category"      
end
