require 'rails_helper'

describe Image do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:image)
      expect(instance).to be_valid
    end
  
  #Shared Examples
    it_behaves_like "it has pagination", "image"  
  
  #Association Test
    it "has many imagelists" do
      expect(create(:image, :with_imagelist_album).imagelists.first).to be_a Imagelist
      expect(Image.reflect_on_association(:imagelists).macro).to eq(:has_many)
    end
    
    it "has many albums" do
      expect(create(:image, :with_imagelist_album).albums.first).to be_a Album
      expect(Image.reflect_on_association(:albums).macro).to eq(:has_many)  
    end
    
    it "has many artists" do
      expect(create(:image, :with_imagelist_artist).artists.first).to be_a Artist
      expect(Image.reflect_on_association(:artists).macro).to eq(:has_many)  
    end
    
    it "has many organizations" do
      expect(create(:image, :with_imagelist_organization).organizations.first).to be_a Organization
      expect(Image.reflect_on_association(:organizations).macro).to eq(:has_many)  
    end
    
    it "has many sources" do
      expect(create(:image, :with_imagelist_source).sources.first).to be_a Source
      expect(Image.reflect_on_association(:sources).macro).to eq(:has_many)  
    end
    
    it "has many songs" do
      expect(create(:image, :with_imagelist_song).songs.first).to be_a Song
      expect(Image.reflect_on_association(:songs).macro).to eq(:has_many)  
    end
    
    it "has many users" do
      expect(create(:image, :with_imagelist_user).users.first).to be_a User
      expect(Image.reflect_on_association(:users).macro).to eq(:has_many)  
    end
        
    it "has many posts" do
      expect(create(:image, :with_imagelist_post).posts.first).to be_a Post
      expect(Image.reflect_on_association(:posts).macro).to eq(:has_many)  
    end    
    
    it "destroys imagelists when destroyed" do
      image = create(:image, :with_imagelist_organization)
      expect{image.destroy}.to change(Imagelist, :count).by(-1)
    end
    
    it "does not destroy other records when destroyed" do
      image = create(:image, :with_imagelist_organization)
      expect{image.destroy}.to change(Organization, :count).by(0)
    end
    
  #Validation Tests

    include_examples "is invalid without an attribute", :image, :name
    include_examples "is invalid without an attribute", :image, :path

    include_examples "is invalid without an attribute in a category", :image, :rating, Image::Rating, "Image::Rating"

    include_examples "is valid with or without an attribute", :image, :rating, "NWS"
    include_examples "is valid with or without an attribute", :image, :medium_path, "this is a medium path"
    include_examples "is valid with or without an attribute", :image, :thumb_path, "this is a medium path"
    include_examples "is valid with or without an attribute", :image, :primary_flag, "this is a medium path"
    
    it "is valid with multiple imagelists" do
       expect(build(:image, :with_multiple_imagelists)).to be_valid
    end
    
    it "is valid with duplicate names" do
      expect(create(:image, name: "hi")).to be_valid
      expect(build(:image, name: "hi")).to be_valid
    end
    
  #Instance Method Tests
    it "returns the first associated record when using 'model'" do
      instance = create(:image, :with_imagelist_album)
      expect(instance.model).to be_a Album
    end
   
  #Hooks
    it "deletes the actual images when destroyed"
    it "deletes the folder the images were in if there are no more images"
    it "calls create_image_thumbnails after being saved"
    
  #Scopes
    it "returns a list of primary images" do
      imagelist = create_list(:image, 6, :primary_flag => "Cover")
      imagelist2 = create_list(:image, 3)
      expect(Image.primary_images).to match_array(imagelist)
    end
end

describe Imagelist do
  #Gutcheck Test
    it "has a valid factory" do
      expect(create(:imagelist)).to be_valid
    end
  
  #Association Tests
    it "belongs to a model" do
      expect(create(:imagelist, :with_album).model).to be_a Album
      expect(Imagelist.reflect_on_association(:model).macro).to eq(:belongs_to)      
    end
    
    it "belongs to a image" do
      expect(create(:imagelist).image).to be_a Image
      expect(Imagelist.reflect_on_association(:image).macro).to eq(:belongs_to)      
    end
    
    it "destroys the image if there are no other imagelists" do
      imagelist = create(:imagelist)
      expect{imagelist.destroy}.to change(Image, :count).by(-1)
    end
    
    it "does not destroy the image if there are other imagelists" do
      image = create(:image)
      imagelist1 = create(:imagelist, image: image)
      imagelist2 = create(:imagelist, image: image)
      imagelist3 = create(:imagelist, image: image)
      expect{imagelist1.destroy}.to change(Image, :count).by(0)
      expect{imagelist2.destroy}.to change(Image, :count).by(0)
      expect{imagelist3.destroy}.to change(Image, :count).by(-1)       
    end
    
  #Validation Tests
  
  
    it_behaves_like "it is a polymorphic join model", :imagelist, "image", "model", "album", ["album", "artist", "organization", "source", "song", "user", "post"]
    
  

            
    
  
end
