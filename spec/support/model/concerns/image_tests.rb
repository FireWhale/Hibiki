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
          imagelist = create(:imagelist, image: image, model: record)
          imagelist = create(:imagelist, image: image2, model: record)
          imagelist = create(:imagelist, model: record)
          expect(record.primary_images).to match_array([image, image2])
        end        
      end
    end    
  end
end
