require 'rails_helper'

include ActionDispatch::TestProcess

module FullUpdateTests

  shared_examples "updates with keys and values" do |model|
      
      it "responds to 'full_update'" do
        expect(model.to_s.capitalize.constantize).to respond_to(:full_update)
      end

      it "responds to 'full_create'" do
        expect(model.to_s.capitalize.constantize).to respond_to(:full_create)
      end
      
      it "responds to 'full_update_attributes'" do
        expect(build(model)).to respond_to(:full_update_attributes)
      end
      
      it "responds to 'full_save'" do
        expect(build(model)).to respond_to(:full_save)
      end
      
      it "updates the record with the right values before 'full_save', so that validation passes"
      
      it "updates with keys and values" do
        record = create(model)
        record2 = create(model)
        if model == :post #Posts don't have names, update the title instead
          model.to_s.capitalize.constantize.full_update([record.id.to_s, record2.id.to_s], [{title: "haha"}, {title: "hoho"}])
          expect(record.reload.title).to eq("haha")
          expect(record2.reload.title).to eq("hoho")              
        else
          model.to_s.capitalize.constantize.full_update([record.id.to_s, record2.id.to_s], [{name: "haha"}, {name: "hoho"}])
          expect(record.reload.name).to eq("haha")
          expect(record2.reload.name).to eq("hoho")          
        end

      end
      
  end
  
  shared_examples "updates with normal attributes" do |model|
    it "updates with normal attributes" do
      record = create(model)
      if model == :post
        record.full_update_attributes({title: "hihi"})
        expect(record.reload.title).to eq("hihi")
      else
        record.full_update_attributes({name: "hihi"})
        expect(record.reload.name).to eq("hihi")
        
      end
    end
  end
  
  shared_examples "can update a primary relationship" do |model, model2, relationship_class, relationship|
    context "it creates #{relationship_class.to_s}" do
      it "creates a #{relationship} with category" do
        record = create(model)
        record2 = create(model2)
        attributes = attributes_for(model)
        category = relationship_class::Categories.sample
        attributes.merge!("new_#{model2.to_s}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_#{model2.to_s}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change(relationship_class, :count).by(1)
        expect(record.send(relationship + "s").first.send(model.to_s)).to eq(record)
        expect(record.send(relationship + "s").first.send(model2.to_s)).to eq(record2)
        expect(record.send(relationship + "s").first.category).to eq(category)
      end
      
      it "creates multiple #{relationship}s" do
        record = create(model)
        record2 = create(model2)
        record3 = create(model2)
        attributes = attributes_for(model)
        category = relationship_class::Categories.sample
        category2 = relationship_class::Categories.sample
        attributes.merge!("new_#{model2.to_s}_ids".to_sym => [record2.id.to_s, record3.id.to_s])
        attributes.merge!("new_#{model2.to_s}_categories".to_sym => [category, category2])
        expect{record.full_update_attributes(attributes)}.to change(relationship_class, :count).by(2)
        expect(record.send(relationship + "s").first.send(model.to_s)).to eq(record)
        expect(record.send(relationship + "s").first.send(model2.to_s)).to eq(record2)
        expect(record.send(relationship + "s").first.category).to eq(category)
        expect(record.send(relationship + "s")[1].send(model2.to_s)).to eq(record3)
        expect(record.send(relationship + "s")[1].category).to eq(category2)
      end
      
      it "does not create a #{relationship} if record does not exist" do
        record = create(model)
        attributes = attributes_for(model)
        category = relationship_class::Categories.sample
        attributes.merge!("new_#{model2.to_s}_ids".to_sym => ["999999"])
        attributes.merge!("new_#{model2.to_s}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change(relationship_class, :count).by(0)        
      end
    end
    
    context "it updates #{relationship_class.to_s}" do
      it "updates a primary #{relationship}s" do
        record = create(model)
        record2 = create(model2)
        attributes = attributes_for(model)
        category = relationship_class::Categories.sample
        primary_relation = create(relationship.to_sym, model => record, model2.to_sym => record2)
        attributes.merge!("update_#{relationship}s".to_sym => {primary_relation.id.to_s => {'category' => category}})
        record.full_update_attributes(attributes)
        expect(primary_relation.reload.category).to eq(category)
      end
      
      it "updates multiple primary #{relationship}s" do
        record = create(model)
        record2 = create(model2)
      end
    end
    
    context "it destroys #{relationship_class.to_s}" do
      it "destroys the  #{relationship}s" do
        record = create(model)
        primary_relation = create(relationship.to_sym, model.to_sym => record)
        attributes = attributes_for(model)
        attributes.merge!("remove_#{relationship}s".to_sym => [primary_relation.id.to_s])
        expect{record.full_update_attributes(attributes)}.to change(relationship_class, :count).by(-1)      
      end
      
      it "can destroy multiple primary #{relationship}" do
        record = create(model)
        number = Array(3..10).sample
        related_list= create_list(relationship.to_sym, number, model.to_sym => record) 
        attributes = attributes_for(model)
        attributes.merge!("remove_#{relationship}s".to_sym => related_list.map(&:id))
        expect{record.full_update_attributes(attributes)}.to change(relationship_class, :count).by(-number)      
      end
    end
  end
  
  shared_examples "can update self-relations" do |model|
    context "it creates self relations" do
      it "creates a self relation" do
        record = create(model)
        record2 = create(model)
        attributes = attributes_for(model)
        if model == :artist
          category = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          category = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        attributes.merge!("new_related_#{model.to_s}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_related_#{model.to_s}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change("Related#{model.to_s.capitalize}s".constantize, :count).by(1)
        expect(record.send("related_#{model.to_s}s")).to eq([record2])
        expect(record.send("related_#{model.to_s}_relations").first.category).to eq(category)
        expect(record.send("related_#{model.to_s}s1")).to eq([record2])    
      end
      
      it "handles a negative relationship properly" do
        record = create(model)
        record2 = create(model)
        attributes = attributes_for(model)
        if model == :artist
          category = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          category = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        attributes.merge!("new_related_#{model.to_s}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_related_#{model.to_s}_categories".to_sym => ["-" + category])
        expect{record.full_update_attributes(attributes)}.to change("Related#{model.to_s.capitalize}s".constantize, :count).by(1)
        expect(record.send("related_#{model.to_s}s")).to eq([record2])
        expect(record.send("related_#{model.to_s}_relations").first.category).to eq(category)  
        expect(record.send("related_#{model.to_s}s2")).to eq([record2])    
      end
      
      it "can create multiple self relations" do
        record = create(model)
        attributes = attributes_for(model)
        number = Array(8..10).sample
        list = create_list(model, number)
        attributes.merge!("new_related_#{model.to_s}_ids".to_sym => list.map(&:id).map(&:to_s))
        cats = []
        number.times do 
          cats = cats + [model.to_s.capitalize.constantize::SelfRelationships.map(&:last).sample]
        end
        attributes.merge!("new_related_#{model.to_s}_categories".to_sym => cats)
        expect{record.full_update_attributes(attributes)}.to change("Related#{model.to_s.capitalize}s".constantize, :count).by(number)
      end
      
    end
    
    context "it updates self relations" do
      it "updates a self relation" do
        record = create(model)
        if model == :artist
          original_cat = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
          category = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          original_cat = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
          category = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        relation = create("related_#{model.to_s}s".to_sym, "#{model.to_s}1".to_sym => record, category: original_cat)
        attributes = attributes_for(model)
        hash = {"#{relation.id.to_s}" => {"category" => category}}        
        attributes.merge!("update_related_#{model.to_s}s".to_sym => hash)
        record.full_update_attributes(attributes)
        expect(relation.reload.category).to eq(category)        
      end
      
      it "updates a negative relationship properly" do
        record = create(model)
        if model == :artist
          original_cat = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
          category = model.to_s.capitalize.constantize::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          original_cat = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
          category = model.to_s.capitalize.constantize::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        relation = create("related_#{model.to_s}s".to_sym, "#{model.to_s}1".to_sym => record, category: original_cat)
        attributes = attributes_for(model)
        hash = {"#{relation.id.to_s}" => {"category" => "-" + category}}        
        attributes.merge!("update_related_#{model.to_s}s".to_sym => hash)
        record.full_update_attributes(attributes)
        expect(relation.reload.category).to eq(category)   
        expect(relation.reload.send("#{model}2")).to eq(record) 
      end      
      
      it "updates multiple self relations and addresses negative relationships accordingly" do
        #Okay I know I shouldn't do multiple expect tests in the same test, but I'm just gonna test everything
        record = create(model)
        number = Array(8..10).sample
        related_list= create_list("related_#{model.to_s}s".to_sym, number, "#{model.to_s}1".to_sym => record) 
        attributes = attributes_for(model)
        hash = {}
        comparehash = {}
        related_list.each do |each|
          cat = model.to_s.capitalize.constantize::SelfRelationships.map(&:last).sample
          hash["#{each.id.to_s}"] = {"category" => cat}
          comparehash["#{each.id.to_s}"] = {"category" => cat}
        end
        attributes.merge!("update_related_#{model.to_s}s".to_sym => hash)
        record.full_update_attributes(attributes)
        comparehash.each do |k, v|
          if v['category'].starts_with?("-")
            expect("Related#{model.to_s.capitalize}s".constantize.find_by_id(k).category).to eq(v['category'].slice(1..-1))
            expect("Related#{model.to_s.capitalize}s".constantize.find_by_id(k).reload.send("#{model}2")).to eq(record)
          else
            expect("Related#{model.to_s.capitalize}s".constantize.find_by_id(k).category).to eq(v['category'])
            expect("Related#{model.to_s.capitalize}s".constantize.find_by_id(k).send("#{model}1")).to eq(record)
          end
        end
      end
            
    end
    
    context "it destroys self relations" do
      it "destroys the self relation" do
        record = create(model)
        related_record = create("related_#{model.to_s}s".to_sym, "#{model}1".to_sym => record)  
        attributes = attributes_for(model)
        attributes.merge!("remove_related_#{model.to_s}s".to_sym => [related_record.id])
        expect{record.full_update_attributes(attributes)}.to change("Related#{model.to_s.capitalize}s".constantize, :count).by(-1)
      end
      
      it "does not destroy the associated record" do
        record = create(model)
        related_record = create("related_#{model.to_s}s".to_sym, "#{model}1".to_sym => record) 
        attributes = attributes_for(model)
        attributes.merge!("remove_related_#{model.to_s}s".to_sym => [related_record.id])
        expect{record.full_update_attributes(attributes)}.to change(model.to_s.capitalize.constantize, :count).by(0)        
      end
      
      it "can destroy multiple self relations" do
        record = create(model)
        number = Array(3..10).sample
        related_list= create_list("related_#{model.to_s}s".to_sym, number, "#{model}1".to_sym => record) 
        attributes = attributes_for(model)
        attributes.merge!("remove_related_#{model.to_s}s".to_sym => related_list.map(&:id))
        expect{record.full_update_attributes(attributes)}.to change("Related#{model.to_s.capitalize}s".constantize, :count).by(-number)      
      end
      
    end
  end
  
  shared_examples "can upload an image" do |model|
    it "creates an image record" #do
    #This raised a MiniMagick::Invalid error on the :after_save because it doesn't copy the image correctly the first time.
      # attributes = attributes_for(model)
      # image = Rack::Test::UploadedFile.new(Rails.root.join("spec", "factories", "image.png"), "image/png")
      # attributes.merge!(:images => [image])
      # record = create(model)
      # expect(record.full_update_attributes(attributes)).to change(Image, :count).by(1)
    # end
    
    context "image attributes" do
      #it "creates an image record with the right path"
      
      #it "creates an image record with the right flag"
    end
    
    #it "associates the image record"
    
    #it "can create multiple image records"
    
    #it "makes it in the right directory"
  end
    
  shared_examples "updates the reference properly" do |model|
    it "updates the reference properly" do
      attributes = attributes_for(model)
      attributes.merge!(reference: {types: ["VGMdb", "vocaloid_DB"], links: ["http://vgmdb.net/album/47999", "http://vocadb.net/Al/9207"]})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.reference).to eq({:VGMdb => "http://vgmdb.net/album/47999", :vocaloid_DB => "http://vocadb.net/Al/9207"})
    end
    
    it "only updates with valid references" do
      attributes = attributes_for(model)
      attributes.merge!(reference: {types: ["VGMdb", "vocaloid_DB", "hola"], links: ["http://vgmdb.net/album/47999", "http://vocadb.net/Al/9207", "hiya"]})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.reference).to eq({:VGMdb => "http://vgmdb.net/album/47999", :vocaloid_DB => "http://vocadb.net/Al/9207"})
    end
  end
  
  shared_examples "updates dates properly" do |model, attribute|
    it "saves the date properly and adds a bitmask" do
      attributes = attributes_for(model)
      attributes.merge!({"#{attribute}(1i)" => "1999",
                         "#{attribute}(2i)" => "",
                         "#{attribute}(3i)" => ""})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1999, 1, 1))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(6)
    end

    it "saves the date properly and adds a bitmask test 2" do
      attributes = attributes_for(model)
      attributes.merge!({"#{attribute}(1i)" => "2013",
                         "#{attribute}(2i)" => "5",
                         "#{attribute}(3i)" => ""})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(2013, 5, 1))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(4)
    end

    it "saves the date properly and adds a bitmask test 3" do
      attributes = attributes_for(model)
      attributes.merge!({"#{attribute}(1i)" => "",
                         "#{attribute}(2i)" => "5",
                         "#{attribute}(3i)" => "2"})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1900, 5, 2))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(1)
    end

    it "does not save the date if no attributes are passed in" do
      attributes = attributes_for(model)
      attributes.merge!({"#{attribute}(1i)" => "",
                         "#{attribute}(2i)" => "",
                         "#{attribute}(3i)" => ""})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(nil)
      expect(record.reload.send("#{attribute}_bitmask")).to eq(nil)
    end

    it "has a bitmask of 0 with all dates present" do
      attributes = attributes_for(model)
      attributes.merge!({"#{attribute}(1i)" => "1993",
                         "#{attribute}(2i)" => "8",
                         "#{attribute}(3i)" => "3"})
      record = create(model)
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1993,8,3))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(0)
    end
      
  end
end
