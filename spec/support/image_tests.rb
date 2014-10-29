require 'rails_helper'

module ImageTests
  shared_examples "it has images" do |model, model_symbol|
    it "is valid with images" do
      expect(build(model_symbol, :with_image)).to be_valid
    end 
    
    it "has many imagelists" do
      expect(create(model_symbol, :with_image).imagelists.first).to be_a Imagelist
      expect(model.reflect_on_association(:imagelists).macro).to eq(:has_many)
    end
    
    it "has many images" do
      expect(create(model_symbol, :with_image).images.first).to be_a Image
      expect(model.reflect_on_association(:images).macro).to eq(:has_many)
    end
    
    it "destroys imagelists when destroyed" do
      record = create(model_symbol, :with_image)
      expect{record.destroy}.to change(Imagelist, :count).by(-1)
    end
    
    it "destroys images if the destroyed imagelist is the only image" do
      record1 = create(model_symbol)
      record2 = create(model_symbol)
      image = create(:image)
      imagelist1 = create(:imagelist, image: image, model: record1)
      imagelist2 = create(:imagelist, image: image, model: record2)
      expect{record1.destroy}.to change(Image, :count).by(0)
      expect{record2.destroy}.to change(Imagelist, :count).by(-1)
    end
  end
end
