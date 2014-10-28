require 'rails_helper'

module ImageTests
  shared_examples "it has images" do |model, model_symbol|
    it "has many imagelists" do
      expect(create(model_symbol, :with_imagelist).imagelists.first).to be_a Imagelist
      expect(model.reflect_on_association(:imagelists).macro).to eq(:has_many)
    end
    
    it "has many images" do
      expect(create(model_symbol, :with_image).images.first).to be_a Image
      expect(model.reflect_on_association(:images).macro).to eq(:has_many)
    end
  end
end
