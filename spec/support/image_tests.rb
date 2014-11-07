require 'rails_helper'

module ImageTests
  shared_examples "it has images" do |model, model_class|
    #Associations
      it "is valid with images" do
        expect(build(model, :with_image)).to be_valid
      end 
      
      it "has many imagelists" do
        expect(create(model, :with_image).imagelists.first).to be_a Imagelist
        expect(model_class.reflect_on_association(:imagelists).macro).to eq(:has_many)
      end
      
      it "has many images" do
        expect(create(model, :with_image).images.first).to be_a Image
        expect(model_class.reflect_on_association(:images).macro).to eq(:has_many)
      end
      
      it "destroys imagelists when destroyed" do
        record = create(model, :with_image)
        expect{record.destroy}.to change(Imagelist, :count).by(-1)
      end
      
      it "has many primary_images" do
        record = create(model)
        if model == :album
          image = create(:image, primary_flag: "Cover")
        else
          image = create(:image, primary_flag: "Primary")
        end
        imagelist = create(:imagelist, image: image, model: record)
        expect(record.primary_images.first).to eq(image)
      end
      
      it "destroys images if the destroyed imagelist is the only image" do
        record1 = create(model)
        record2 = create(model)
        image = create(:image)
        imagelist1 = create(:imagelist, image: image, model: record1)
        imagelist2 = create(:imagelist, image: image, model: record2)
        expect{record1.destroy}.to change(Image, :count).by(0)
        expect{record2.destroy}.to change(Image, :count).by(-1)
      end
    
    #validations
      it "is valid with multiple imagelists and images" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(:imagelist, number, model: record)
        expect(record.imagelists).to match_array(list)
        expect(record.images.count).to eq(number)
        expect(record).to be_valid
      end
    
    #Callbacks   
      # it "cleans up the folder where images are stored if there are no remaining images"
      # This is covered by a before_destroy callback in images
  end
end
