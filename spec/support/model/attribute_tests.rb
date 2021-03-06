require 'rails_helper'

module AttributeTests

  #Common Tests
    shared_examples "is invalid without an attribute" do |attribute|
      class_symbol = described_class.model_name.param_key.to_sym

      it "is valid with an #{attribute.to_s}" do
        #The factories should inclue such attributes
        expect(build(class_symbol)).to be_valid
      end

      it "is invalid without an #{attribute.to_s}" do
        expect(build(class_symbol, attribute => nil)).not_to be_valid
        expect(build(class_symbol, attribute => "")).to_not be_valid
      end
    end

    shared_examples "is invalid without an attribute in a category" do |attribute, category, category_name|
      class_symbol = described_class.model_name.param_key.to_sym

      it "is valid with a #{attribute.to_s} contained in #{category_name}" do
        expect(build(class_symbol, attribute => category.sample)).to be_valid
      end

      it "is invalid without a #{attribute.to_s} contained in #{category_name}" do
        record = create(class_symbol)
        record.send("#{attribute}=".to_sym, "heheheha")
        expect(record).to_not be_valid
      end
    end

    shared_examples "is valid with or without an attribute" do |attribute, value|
      model_symbol = described_class.model_name.param_key.to_sym

      it "is valid with a #{attribute.to_s}" do
        expect(build(model_symbol, attribute => value)).to be_valid
      end

      it "is valid without a #{attribute.to_s}" do
        expect(build(model_symbol, attribute => "")).to be_valid
        expect(build(model_symbol, attribute => nil)).to be_valid
      end
    end


  #Attribute Accessor
    shared_examples "attribute accessor methods" do |model, attribute|
      it "has access to the '#{attribute}' getter method" do
        expect(build(model)).to respond_to(attribute)
      end
      it "has access to the '#{attribute}' setter method" do
        expect(build(model)).to respond_to((attribute.to_s + "=").to_sym)
      end
    end

  #Serialized Attributes
    shared_examples "it has a serialized attribute" do |attribute|
      model_symbol = described_class.model_name.param_key.to_sym

      include_examples "is valid with or without an attribute", attribute, {:hi => 'ho', 'ho' => 'hi'}

      it "returns the #{attribute} as a hash" do
        instance = create(model_symbol, attribute => {:hi => 'ho', 'ho' => 'hi'})
        expect(instance.reload.send(attribute.to_s)).to be_a Hash
      end

      it "returns an #{described_class.model_name.singular}'s #{attribute.to_s} as a hash" do
        instance = create(model_symbol, attribute => {:hi => 'ho', 'ho' => 'hi'})
        expect(instance.reload.send(attribute.to_s)).to eq({"hi" => 'ho', 'ho' => 'hi'})
      end
    end

  #Scopes on attributes
    shared_examples "it reports released records" do |model|
      it "reports released records" do
        @released = create_list(model, 3, status: "Released")
        @unreleased = create_list(model, 2, status: "Unreleased")
        expect(model.to_s.capitalize.constantize.released).to match_array(@released)
      end
    end
end
