require 'rails_helper'

module ImageTests
  shared_examples "it has images" do
    describe "Image Tests" do
      model_symbol = described_class.model_name.param_key.to_sym

      describe "Associations" do
        it "has many imagelists" do
          expect(create(model_symbol, :with_image).imagelists.first).to be_a Imagelist
          expect(described_class.reflect_on_association(:imagelists).macro).to eq(:has_many)
        end

        it "has many images" do
          expect(create(model_symbol, :with_image).images.first).to be_a Image
          expect(described_class.reflect_on_association(:images).macro).to eq(:has_many)
        end

        it "has many primary_images" do
          expect(described_class.reflect_on_association(:primary_images).macro).to eq(:has_many)
        end

        it "destroys imagelists when destroyed" do
          record = create(model_symbol, :with_image)
          expect{record.destroy}.to change(Imagelist, :count).by(-1)
        end

        it "destroys images if the destroyed imagelist is the only image" do
          #Unnecessary test (should be in the image test) but I like it.
          record1 = create(model_symbol)
          record2 = create(model_symbol)
          image = create(:image)
          imagelist1 = create(:imagelist, image: image, model: record1)
          imagelist2 = create(:imagelist, image: image, model: record2)
          expect{record1.destroy}.to change(Image, :count).by(0)
          expect{record2.destroy}.to change(Image, :count).by(-1)
        end

        it "returns a list of images associated with this #{model_symbol}" do
          #This tests the :through option
          record = create(model_symbol)
          list = create_list(:imagelist, 3, model: record)
          expect(record.images).to match_array(list.map(&:image))
        end

        it "returns a list of primary_images" do
          #This tests the through and where option
          record = create(model_symbol)
          image = create(:image, primary_flag: "Primary")
          image2 = create(:image, primary_flag: "Primary")
          image3 = create(:image, primary_flag: nil)
          record.images << image
          record.images << image2
          record.images << image3
          expect(record.reload.primary_images).to match_array([image, image2])
        end
      end

      describe "Callbacks/Hooks" do
        describe "After Save: add_images" do
          it "makes an image record from image form records" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            expect{record.save}.to change(Image, :count).by(1)
          end

          it "stores the image in the image directory" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            record.save
            full_path = Rails.root.join(Rails.application.secrets.image_directory,record.images.first.path)
            expect(File).to exist(full_path)
          end

          it "assigns a primary flag if it's the first image" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            expect{record.save}.to change(Image, :count).by(1)
          end

          it "removes the attributes after creating the image" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            record.save
            expect(record.new_images).to be_nil
          end

          it "adds an incremental number to the name and path if it exists" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            expect{record.save}.to change(Image, :count).by(1)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            expect{record.save}.to change(Image, :count).by(1)
            expect(record.images[1].name).to eq("test_image 1")
          end

          it "assigns a primary flag of '' if it's not the first image" do
            record = build(model_symbol)
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            record.save
            record.new_images = [ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/support/data/test_image.png", 'rb'), :filename => 'test_image.png')]
            record.save
            expect(record.images[1].primary_flag).to be_empty
          end

        end

        describe "After Save: add_image_paths" do
          it "creates an image record" do
            record = create(model_symbol)
            record.image_names = ["Booklet Front"]
            record.image_paths = ["albums/1/Booklet Front.jpg"]
            expect{record.save}.to change(Image, :count).by(1)
          end
        end
      end
    end
  end
end
