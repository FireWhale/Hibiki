require 'rails_helper'

describe Image do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:image)
      expect(instance).to be_valid
    end
    
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
    it "is valid with a name and path" do
      expect(build(:image)).to be_valid
    end
    
    it "is valid with multiple imagelists" do
       expect(build(:image, :with_multiple_imagelists)).to be_valid
    end
    
    it "is invalid without a name" do
      expect(build(:image, name: "")).to_not be_valid
      expect(build(:image, name: nil)).to_not be_valid
    end
    
    it "is invalid without a path" do
      expect(build(:image, path: "")).to_not be_valid
      expect(build(:image, path: nil)).to_not be_valid
    end
    
    it "is valid without a medium path" do
      expect(build(:image, medium_path: "")).to be_valid
      expect(build(:image, medium_path: nil)).to be_valid     
    end
    
    it "is valid without a thumb path" do
      expect(build(:image, thumb_path: "")).to be_valid
      expect(build(:image, thumb_path: nil)).to be_valid     
    end
    
    it "is valid without a primary flag" do
      expect(build(:image, primary_flag: "")).to be_valid
      expect(build(:image, primary_flag: nil)).to be_valid     
    end
    
    it "is valid without a rating" do
      expect(build(:image, rating: "")).to be_valid
      expect(build(:image, rating: nil)).to be_valid       
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
   
  #Class Method Tests
    it "deletes the actual images when destroyed"
    
    it "deletes the folder the images were in if there are no more images"
  
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
    it "is valid with a image and a model" do
      expect(build(:imagelist)).to be_valid
    end
    
    it "is valid with an album" do
      expect(build(:imagelist, :with_album)).to be_valid
    end
    
    it "is valid with an artist" do
      expect(build(:imagelist, :with_artist)).to be_valid
    end
    
    it "is valid with an organization" do
      expect(build(:imagelist, :with_organization)).to be_valid
    end
    
    it "is valid with a user" do
      expect(build(:imagelist, :with_user)).to be_valid
    end
    
    it "is valid with a source" do
      expect(build(:imagelist, :with_source)).to be_valid
    end
        
    it "is valid with a post" do
      expect(build(:imagelist, :with_post)).to be_valid
    end
        
    it "is invalid without a image" do
      expect(build(:imagelist, image: nil)).to_not be_valid
    end
    
    it "is invalid without a real image" do
      expect(build(:imagelist, image_id: 999999999)).to_not be_valid
    end
    
    it "is invalid without a model_type" do
      expect(build(:imagelist, model_type: nil)).to_not be_valid      
    end

    it "is invalid without a model_id" do
      expect(build(:imagelist, model_id: nil)).to_not be_valid      
    end
    
    it "is invalid without a real model" do
      expect(build(:imagelist, model_type: "Album", model_id: 999999999)).to_not be_valid      
    end
    
    it "should have a unique image/model combination" do
      @image = create(:image)
      @subject = create(:album)
      expect(create(:imagelist, image: @image, model: @subject)).to be_valid
      expect(build(:imagelist, image: @image, model: @subject)).to_not be_valid      
    end
  
end
