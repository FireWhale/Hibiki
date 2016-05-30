require 'rails_helper'

describe Image do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has a custom json method"
    include_examples "it has custom pagination"

    include_examples "it has form_fields"
  end

  describe "Callbacks/Hooks" do
    describe "Before Destroy: delete_images" do
      it "receives delete_images on destroy" do
        image = create(:image)
        expect(image).to receive(:delete_images)
        image.destroy
      end

      it "deletes the actual image when destroyed" do
        album = create(:album)
        album.update_attributes(attributes_for(:album, :image_form_attributes))#creates an actual image
        image = album.images.first
        full_path = Rails.root.join(Rails.application.secrets.image_directory,image.path)
        expect(File).to exist(full_path)
        image.destroy
        expect(File).to_not exist(full_path)
      end

      it "deletes the folder the images were in if there are no more images" do
        album = create(:album)
        album.update_attributes(attributes_for(:album, :image_form_attributes))#creates an actual image
        image = album.images.first
        full_path = Rails.root.join(Rails.application.secrets.image_directory,image.path)
        directory = full_path.dirname
        expect(File).to exist(directory)
        image.destroy
        expect(File).to_not exist(directory)
      end
    end

    describe "After Save: create_image_thumbnails" do
      it "receives create_image_thumbnails after save" do
        image = create(:image)
        expect(image).to receive(:create_image_thumbnails)
        image.save
      end

      it "creates thumbnails" do #Uses an image that is greater than 500x500
        image_file = ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/large_test_image.jpg", 'rb'), :filename => 'large_test_image.jpg')
        album = create(:album, new_images: [image_file])
        image = album.images.first
        full_path = Rails.root.join(Rails.application.secrets.image_directory,image.path)
        expect(File).to exist(full_path)
        medium_path = Rails.root.join(Rails.application.secrets.image_directory,image.medium_path)
        expect(File).to exist(medium_path)
        thumb_path = Rails.root.join(Rails.application.secrets.image_directory,image.thumb_path)
        expect(File).to exist(thumb_path)
      end

      it "adds info to the image record" do
        image_file = ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/large_test_image.jpg", 'rb'), :filename => 'large_test_image.jpg')
        album = create(:album, new_images: [image_file])
        image = album.images.first
        expect(image.width).to eq(738)
        expect(image.medium_path).to_not be_empty
        expect(image.medium_height).to eq(500)
      end
    end
  end

  describe "Association Tests" do
    it_behaves_like "it is a polymorphically-linked class", Imagelist, [Album, Artist, Organization, Source, Song, User, Season, Post], "model"
  end

  describe "Validation Tests" do
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
  end

  describe "Scoping Tests" do
    it "returns a list of primary images" do
      imagelist = create_list(:image, 6, :primary_flag => "Cover")
      imagelist2 = create_list(:image, 3)
      expect(Image.primary_images).to match_array(imagelist)
    end
  end

  describe "Instance Methods" do
    describe "models" do
      it "returns a list of all associated records in an array" do
        album = create(:album)
        artist = create(:artist)
        image = create(:image)
        create(:imagelist, image: image, model: album )
        create(:imagelist, image: image, model: artist )
        expect(image.models).to match_array([album,artist])
      end
    end

    describe "model" do
      it "returns the first record of models" do
        album = create(:album)
        artist = create(:artist)
        image = create(:image)
        create(:imagelist, image: image, model: album )
        create(:imagelist, image: image, model: artist )
        expect([album,artist]).to include(image.model)
      end
    end
  end

end

describe Imagelist do
  include_examples "global model tests" #Global Tests

  it_behaves_like "it is a polymorphic join model", Image, [Album, Artist, Organization, Source, Song, User, Post, Season], "model"

  describe "Callbacks/Hooks"
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
