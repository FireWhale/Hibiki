require 'rails_helper'

module GlobalModelTests  
  shared_examples "global model tests" do
    #Gutcheck
    it "has a valid factory" do
      instance = create(described_class.model_name.param_key.to_sym)
      expect(instance).to be_valid
    end
  end
  
  shared_examples "it has form_fields" do
    it "has a form_field constant" do
      expect(described_class.const_defined?("FormFields")).to be_truthy
    end
  end
end
