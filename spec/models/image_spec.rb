require 'rails_helper'

describe Image do
  include_examples "global model tests" #Global Tests
  
  describe "Module Tests" do
    it_behaves_like "it has pagination"
    it_behaves_like "it has form_fields"
  end
  
  #Association Test
    it_behaves_like "it is a polymorphically-linked class", Imagelist, [Album, Artist, Organization, Source, Song, User, Season, Post], "model"
    
  #Validation Tests

    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :path

    include_examples "is invalid without an attribute in a category", :rating, Image::Rating, "Image::Rating"

    include_examples "is valid with or without an attribute", :rating, "NWS"
    include_examples "is valid with or without an attribute", :medium_path, "this is a medium path"
    include_examples "is valid with or without an attribute", :thumb_path, "this is a medium path"
    include_examples "is valid with or without an attribute", :primary_flag, "this is a medium path"
    
    it "is valid with multiple imagelists" do
       expect(build(:image, :with_multiple_imagelists)).to be_valid
    end
    
    it "is valid with duplicate names" do
      expect(create(:image, name: "hi")).to be_valid
      expect(build(:image, name: "hi")).to be_valid
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
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "it is a polymorphic join model", Image, [Album, Artist, Organization, Source, Song, User, Post, Season], "model"
  
  #Extra tests
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
    
      
end
