require 'rails_helper'

module LanguageTests  
  shared_examples "it is a translated model" do
    describe "Translation Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      attributes = described_class.translated_attribute_names
      
      attributes.each do |attribute|
        describe "read_#{attribute} method" do
          it "has a read_#{attribute} method" do
            expect(build(model_symbol)).to respond_to("read_#{attribute}")
          end
          
          it "can receive a user" do
            expect(build(model_symbol)).to respond_to("read_#{attribute}").with(1).arguments           
          end
          
          it "returns an array" do
            expect(build(model_symbol).send("read_#{attribute}")).to be_a(Array)
          end
          
          it "includes at least the translated_elements" do
            record = build(model_symbol)
            record.write_attribute(attribute, "this is a value")
            expect(record.send("read_#{attribute}")).to include("this is a value")
          end
          
          #I don't think I'll test any other outputs. They work and I don't see them changing
          #any time soon.
        end
      end
    end
  end
end
