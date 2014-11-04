require 'rails_helper'

module AttributeTests
  #Specific Tests
    shared_examples "name/reference combinations" do |model|     
      if model == :album
        #Add extra tests for album
        it "is invalid with a duplicate name/reference/catalogn combination" do
          expect(create(model, name: "hihi", reference: {:hi => "ho"}, catalog_number: "ho")).to be_valid
          expect(build(model, name: "hihi", reference: {:hi => "ho"}, catalog_number: "ho")).not_to be_valid
        end
        
        it "is valid with duplicate catalog_numbers" do
          expect(create(model, catalog_number: "hihi")).to be_valid
          expect(build(model, catalog_number: "hihi")).to be_valid
        end 
      elsif model == :song
        #Do not test this, cause it changes if it has an album or not
      else
        it "is invalid with a duplicate name/reference combination" do
          expect(create(model, name: "hihi", reference: {:hi => "ho"})).to be_valid
          expect(build(model, name: "hihi", reference: {:hi => "ho"})).not_to be_valid
        end        
      end
      
      it "is valid with duplicate names" do
        expect(create(model, name: "hihi")).to be_valid
        expect(build(model, name: "hihi")).to be_valid
      end 
   
      it "is valid with duplicate references" do
        expect(create(model, reference: {:hi => "ho"})).to be_valid
        expect(build(model, reference: {:hi => "ho"})).to be_valid
      end
      
    end
  
    shared_examples "redirects to a new record when db_status is hidden" do |model, categories|
      #Scope Tests
        it "reports hidden records with no pointer record" 
      
    end
  
  #Common Tests
    shared_examples "is invalid without an attribute" do |model, attribute|
      it "is valid with an #{attribute.to_s}" do
        #The factories should inclue such attributes
        expect(build(model)).to be_valid
      end
      
      it "is invalid without an #{attribute.to_s}" do
        expect(build(model, attribute => nil)).not_to be_valid  
        expect(build(model, attribute => "")).to_not be_valid  
      end

      it "has a #{attribute.to_s} that is accessible" do
        expect(build(model).class.accessible_attributes.include?(attribute)).to be true
      end
    end
    
    shared_examples "is invalid without an attribute in a category" do |model, attribute, category, category_name|
      it "is valid with a #{attribute.to_s} contained in #{category_name}" do
        expect(build(model, attribute => category.sample)).to be_valid
      end
      
      it "is invalid without a #{attribute.to_s} contained in #{category_name}" do
        expect(build(model, attribute => "heheheha")).to_not be_valid      
      end
    end
    
    shared_examples "is valid with or without an attribute" do |model, attribute, value|
      it "is valid with a #{attribute.to_s}" do
        expect(build(model, attribute => value)).to be_valid
      end    
      
      it "is valid without a #{attribute.to_s}" do
        expect(build(model, attribute => "")).to be_valid
        expect(build(model, attribute => nil)).to be_valid
      end
      
      it "has a #{attribute.to_s} that is accessible" do
        expect(build(model).class.accessible_attributes.include?(attribute)).to be true
      end
    end

    shared_examples "it has a partial date" do |model, attribute|
      #Validations
        it "has a #{attribute} that is accessible" do
          expect(build(model).class.accessible_attributes.include?(attribute)).to be true
        end
        
        it "has a #{attribute}_bitmask that is accessible" do
          expect(build(model).class.accessible_attributes.include?("#{attribute}_bitmask")).to be false
        end
        
        it "is valid with a #{attribute} and #{attribute}_bitmask" do
          expect(build(model, attribute.to_sym => Date.today, "#{attribute}_bitmask".to_sym => 2)).to be_valid
        end
        
        it "is valid without both a #{attribute} and #{attribute}_bitmask" do
          expect(build(model, attribute.to_sym => nil, "#{attribute}_bitmask".to_sym => nil)).to be_valid
        end
     
        it "is not valid if it has a #{attribute} and not a #{attribute}_bitmask" do
          expect(build(model, attribute.to_sym => Date.today, "#{attribute}_bitmask".to_sym => nil)).to_not be_valid            
        end
        
        it "is not valid if it has a #{attribute}_bitmask and not a #{attribute}" do
          expect(build(model, attribute.to_sym => nil, "#{attribute}_bitmask".to_sym => 2)).to_not be_valid 
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
    shared_examples "it has a serialized attribute" do |model, attribute|
      include_examples "is valid with or without an attribute", model, attribute, {:hi => 'ho', 'ho' => 'hi'}
      
      it "returns the #{attribute} as a hash" do
        instance = create(model, attribute => {:hi => 'ho', 'ho' => 'hi'})
        expect(instance.reload.send(attribute.to_s)).to be_a Hash
      end
      
      it "returns an #{model.to_s}'s #{attribute.to_s} as a hash" do
        instance = create(model, attribute => {:hi => 'ho', 'ho' => 'hi'})
        expect(instance.reload.send(attribute.to_s)).to eq({:hi => 'ho', 'ho' => 'hi'})
      end
    end
end
