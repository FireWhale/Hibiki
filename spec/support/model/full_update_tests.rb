require 'rails_helper'

include ActionDispatch::TestProcess

module FullUpdateTests

  shared_examples "updates with keys and values" do
    model_symbol = described_class.model_name.param_key.to_sym
  
    it "has a fullupdatefields constant" do
      expect(described_class.const_defined?("FullUpdateFields")).to be_truthy
    end
    
    it "responds to 'full_update'" do
      expect(described_class).to respond_to(:full_update)
    end

    it "responds to 'full_create'" do
      expect(described_class).to respond_to(:full_create)
    end
    
    it "responds to 'full_update_attributes'" do
      expect(build(model_symbol)).to respond_to(:full_update_attributes)
    end
    
    it "responds to 'full_save'" do
      expect(build(model_symbol)).to respond_to(:full_save)
    end
    
    it "updates the record with the right values before 'full_create'" do
      record = build(model_symbol)
      attributes = attributes_for(model_symbol)
      expect{record.full_save(attributes)}.to change(described_class,:count).by(1)
    end
    
    it "passes values through and formats them" do
      record = build(model_symbol)
      attributes = attributes_for(model_symbol)
      unless described_class == Post || described_class == Tag || described_class == Season #don't need to test reference with posts
        attributes.merge!(reference: {types: ["VGMdb", "vocaloid_DB"], links: ["http://vgmdb.net/album/47999", "http://vocadb.net/Al/9207"]})
      end
      expect{record.full_save(attributes)}.to change(described_class,:count).by(1)
      unless described_class == Post || described_class == Tag || described_class == Season
        expect(record.reload.reference).to eq({:VGMdb => "http://vgmdb.net/album/47999", :vocaloid_DB => "http://vocadb.net/Al/9207"})        
      end
    end
        
    it "creates with keys and values" 
    
    it "updates with keys and values" do
      record = create(model_symbol)
      record2 = create(model_symbol)
      if described_class == Post #Posts don't have names, update the title instead
        described_class.full_update([record.id.to_s, record2.id.to_s], [{title: "haha"}, {title: "hoho"}])
        expect(record.reload.title).to eq("haha")
        expect(record2.reload.title).to eq("hoho")              
      else
        described_class.full_update([record.id.to_s, record2.id.to_s], [{name: "haha"}, {name: "hoho"}])
        expect(record.reload.name).to eq("haha")
        expect(record2.reload.name).to eq("hoho")          
      end

    end
    
  end
  
  shared_examples "updates with normal attributes" do
    it "updates with normal attributes" do
      record = create(described_class.model_name.param_key.to_sym)
      if described_class == Post
        record.full_update_attributes({title: "hihi"})
        expect(record.reload.title).to eq("hihi")
      else
        record.full_update_attributes({name: "hihi"})
        expect(record.reload.name).to eq("hihi")
        
      end
    end
  end
  
  shared_examples "can update a primary relationship" do |related_class, join_class|
    model_symbol = described_class.model_name.param_key.to_sym
    model_string = described_class.model_name.singular
    related_model_symbol = related_class.model_name.param_key.to_sym
    related_model_string = related_class.model_name.singular
    join_model_symbol = join_class.model_name.param_key.to_sym
    join_model_string = join_class.model_name.singular
    
    context "it creates #{join_model_string}" do
      it "creates a #{join_model_string} with category" do
        record = create(model_symbol)
        record2 = create(related_model_symbol)
        attributes = attributes_for(model_symbol)
        category = join_class::Categories.sample
        attributes.merge!("new_#{related_model_string}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_#{related_model_string}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change(join_class, :count).by(1)
        expect(record.send("#{join_model_string}s").first.send(model_string)).to eq(record)
        expect(record.send("#{join_model_string}s").first.send(related_model_string)).to eq(record2)
        expect(record.send("#{join_model_string}s").first.category).to eq(category)
      end
      
      it "creates multiple #{join_model_string}s" do
        record = create(model_symbol)
        record2 = create(related_model_symbol)
        record3 = create(related_model_symbol)
        attributes = attributes_for(model_symbol)
        category = join_class::Categories.sample
        category2 = join_class::Categories.sample
        attributes.merge!("new_#{related_model_string}_ids".to_sym => [record2.id.to_s, record3.id.to_s])
        attributes.merge!("new_#{related_model_string}_categories".to_sym => [category, category2])
        expect{record.full_update_attributes(attributes)}.to change(join_class, :count).by(2)
        expect(record.send("#{join_model_string}s").first.send(model_string)).to eq(record)
        expect(record.send("#{join_model_string}s").first.send(related_model_string)).to eq(record2)
        expect(record.send("#{join_model_string}s").first.category).to eq(category)
        expect(record.send("#{join_model_string}s")[1].send(related_model_string)).to eq(record3)
        expect(record.send("#{join_model_string}s")[1].category).to eq(category2)
      end
      
      it "does not create a #{join_model_string} if record does not exist" do
        record = create(model_symbol)
        attributes = attributes_for(model_symbol)
        category = join_class::Categories.sample
        attributes.merge!("new_#{related_model_string}_ids".to_sym => ["999999"])
        attributes.merge!("new_#{related_model_string}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change(join_class, :count).by(0)        
      end
    end
    
    context "it updates #{join_model_string}" do
      it "updates a #{join_model_string}s" do
        record = create(model_symbol)
        record2 = create(related_model_symbol)
        attributes = attributes_for(model_symbol)
        category = join_class::Categories.sample
        primary_relation = create(join_model_symbol, model_symbol => record, related_model_symbol => record2)
        attributes.merge!("update_#{join_model_string}s".to_sym => {primary_relation.id.to_s => {'category' => category}})
        record.full_update_attributes(attributes)
        expect(primary_relation.reload.category).to eq(category)
      end
      
      it "updates multiple primary #{join_model_string}s" do
        record = create(model_symbol)
        record2 = create(related_model_symbol)
        record3 = create(related_model_symbol)
        attributes = attributes_for(model_symbol)
        category1 = join_class::Categories.sample
        category2 = join_class::Categories.sample
        primary_relation1 = create(join_model_symbol, model_symbol => record, related_model_symbol => record2)
        primary_relation2 = create(join_model_symbol, model_symbol => record, related_model_symbol => record3)
        attributes.merge!("update_#{join_model_string}s".to_sym => {primary_relation1.id.to_s => {'category' => category1}, primary_relation2.id.to_s => {'category' => category2}})
        record.full_update_attributes(attributes)
        expect(primary_relation1.reload.category).to eq(category1)
        expect(primary_relation2.reload.category).to eq(category2)
      end
    end
    
    context "it destroys #{join_model_string}" do
      it "destroys the  #{join_model_string}s" do
        record = create(model_symbol)
        primary_relation = create(join_model_symbol, model_symbol => record)
        attributes = attributes_for(model_symbol)
        attributes.merge!("remove_#{join_model_string}s".to_sym => [primary_relation.id.to_s])
        expect{record.full_update_attributes(attributes)}.to change(join_class, :count).by(-1)      
      end
      
      it "can destroy multiple #{join_model_string}s" do
        record = create(model_symbol)
        number = Array(3..10).sample
        related_list= create_list(join_model_symbol, number, model_symbol => record) 
        attributes = attributes_for(model_symbol)
        attributes.merge!("remove_#{join_model_string}s".to_sym => related_list.map(&:id))
        expect{record.full_update_attributes(attributes)}.to change(join_class, :count).by(-number)      
      end
    end
  end
  
  shared_examples "updates namehash properly" do 
    context "it updates the namehash properly" do
      model_symbol = described_class.model_name.param_key.to_sym
      model_string = described_class.model_name.singular
      
      it "adds the namehash to the #{model_string}" do
        record = create(model_symbol)
        attributes = attributes_for(model_symbol)
        attributes.merge!(:namehash => {:English => "hey", :Romaji => "hola"})
        record.full_update_attributes(attributes)
        record.reload
        expect(record.namehash).to eq({:English => "hey", :Romaji => "hola"})
      end
      
      it "removes blank languages from the hash" do
        record = create(model_symbol)
        attributes = attributes_for(model_symbol)
        attributes.merge!(:namehash => {:English => "hey", :Romaji => "hola", :Japanese => ""})
        record.full_update_attributes(attributes)
        record.reload
        expect(record.namehash).to eq({:English => "hey", :Romaji => "hola"})
      end
    end
  end
  
  shared_examples "can update self-relations" do
    model_symbol = described_class.model_name.param_key.to_sym
    model_string = described_class.model_name.singular
    join_table_class = "Related#{model_string.capitalize}s".constantize
    join_table_string = join_table_class.model_name.singular
    join_table_symbol = join_table_class.model_name.param_key.to_sym
    
    context "it creates self relations" do
      it "creates a self relation" do
        record = create(model_symbol)
        record2 = create(model_symbol)
        attributes = attributes_for(model_symbol)
        if described_class == Artist
          category = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          category = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        attributes.merge!("new_related_#{model_string}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_related_#{model_string}_categories".to_sym => [category])
        expect{record.full_update_attributes(attributes)}.to change(join_table_class, :count).by(1)
        expect(record.send(join_table_string)).to eq([record2])
        expect(record.send("related_#{model_string}_relations").first.category).to eq(category)
        expect(record.send("related_#{model_string}s1")).to eq([record2])    
      end
      
      it "handles a negative relationship properly" do
        record = create(model_symbol)
        record2 = create(model_symbol)
        attributes = attributes_for(model_symbol)
        if described_class == Artist
          category = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          category = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        attributes.merge!("new_related_#{model_string}_ids".to_sym => [record2.id.to_s])
        attributes.merge!("new_related_#{model_string}_categories".to_sym => ["-" + category])
        expect{record.full_update_attributes(attributes)}.to change(join_table_class, :count).by(1)
        expect(record.send(join_table_string)).to eq([record2])
        expect(record.send("related_#{model_string}_relations").first.category).to eq(category)  
        expect(record.send("related_#{model_string}s2")).to eq([record2])    
      end
      
      it "can create multiple self relations" do
        record = create(model_symbol)
        attributes = attributes_for(model_symbol)
        number = Array(8..10).sample
        list = create_list(model_symbol, number)
        attributes.merge!("new_related_#{model_string}_ids".to_sym => list.map(&:id).map(&:to_s))
        cats = []
        number.times do 
          cats = cats + [described_class::SelfRelationships.map(&:last).sample]
        end
        attributes.merge!("new_related_#{model_string}_categories".to_sym => cats)
        expect{record.full_update_attributes(attributes)}.to change(join_table_class, :count).by(number)
      end
      
    end
    
    context "it updates self relations" do
      it "updates a self relation" do
        record = create(model_symbol)
        if described_class == Artist
          original_cat = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
          category = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          original_cat = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
          category = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        relation = create(join_table_symbol, "#{model_string}1".to_sym => record, category: original_cat)
        attributes = attributes_for(model_symbol)
        hash = {"#{relation.id.to_s}" => {"category" => category}}        
        attributes.merge!("update_related_#{model_string}s".to_sym => hash)
        record.full_update_attributes(attributes)
        expect(relation.reload.category).to eq(category)        
      end
      
      it "updates a negative relationship properly" do
        record = create(model_symbol)
        if described_class == Artist
          original_cat = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
          category = described_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last).sample
        else
          original_cat = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
          category = described_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?).sample 
        end
        relation = create(join_table_symbol, "#{model_string}1".to_sym => record, category: original_cat)
        attributes = attributes_for(model_symbol)
        hash = {"#{relation.id.to_s}" => {"category" => "-" + category}}        
        attributes.merge!("update_related_#{model_string}s".to_sym => hash)
        record.full_update_attributes(attributes)
        expect(relation.reload.category).to eq(category)   
        expect(relation.reload.send("#{model_string}2")).to eq(record) 
      end      
      
      it "updates multiple self relations and addresses negative relationships accordingly" do
        #Okay I know I shouldn't do multiple expect tests in the same test, but I'm just gonna test everything
        record = create(model_symbol)
        number = Array(8..10).sample
        related_list= create_list(join_table_symbol, number, "#{model_string}1".to_sym => record) 
        attributes = attributes_for(model_symbol)
        hash = {}
        comparehash = {}
        related_list.each do |each|
          cat = described_class::SelfRelationships.map(&:last).sample
          hash["#{each.id.to_s}"] = {"category" => cat}
          comparehash["#{each.id.to_s}"] = {"category" => cat}
        end
        attributes.merge!("update_related_#{model_string}s".to_sym => hash)
        record.full_update_attributes(attributes)
        comparehash.each do |k, v|
          if v['category'].starts_with?("-")
            expect(join_table_class.find_by_id(k).category).to eq(v['category'].slice(1..-1))
            expect(join_table_class.find_by_id(k).reload.send("#{model_string}2")).to eq(record)
          else
            expect(join_table_class.find_by_id(k).category).to eq(v['category'])
            expect(join_table_class.find_by_id(k).send("#{model_string}1")).to eq(record)
          end
        end
      end
    end
    
    context "it destroys self relations" do
      it "destroys the self relation" do
        record = create(model_symbol)
        related_record = create(join_table_symbol, "#{model_string}1".to_sym => record)  
        attributes = attributes_for(model_symbol)
        attributes.merge!("remove_related_#{model_string}s".to_sym => [related_record.id])
        expect{record.full_update_attributes(attributes)}.to change(join_table_class, :count).by(-1)
      end
      
      it "does not destroy the associated record" do
        record = create(model_symbol)
        related_record = create(join_table_symbol, "#{model_string}1".to_sym => record) 
        attributes = attributes_for(model_symbol)
        attributes.merge!("remove_related_#{model_string}s".to_sym => [related_record.id])
        expect{record.full_update_attributes(attributes)}.to change(described_class, :count).by(0)        
      end
      
      it "can destroy multiple self relations" do
        record = create(model_symbol)
        number = Array(3..10).sample
        related_list= create_list(join_table_symbol, number, "#{model_string}1".to_sym => record) 
        attributes = attributes_for(model_symbol)
        attributes.merge!("remove_related_#{model_string}s".to_sym => related_list.map(&:id))
        expect{record.full_update_attributes(attributes)}.to change(join_table_class, :count).by(-number)      
      end
      
    end
  end
  
  shared_examples "can upload an image" do 
    it "can upload an image" #do
    #This raised a MiniMagick::Invalid error on the :after_save because it doesn't copy the image correctly the first time.
      # attributes = attributes_for(model)
      # image = Rack::Test::UploadedFile.new(Rails.root.join("spec", "factories", "image.png"), "image/png")
      # attributes.merge!(:images => [image])
      # record = create(model)
      # expect(record.full_update_attributes(attributes)).to change(Image, :count).by(1)
    # end
    
    context "image attributes" do
      # it "creates an image record with the right path"
      
      # it "creates an image record with the right flag"
    end
    
    # it "associates the image record"
    
    # it "can create multiple image records"
    
    # it "makes it in the right directory"
  end
    
  shared_examples "updates the reference properly" do
    model_symbol = described_class.model_name.param_key.to_sym
    
    it "updates the reference properly" do
      attributes = attributes_for(model_symbol)
      attributes.merge!(reference: {types: ["VGMdb", "vocaloid_DB"], links: ["http://vgmdb.net/album/47999", "http://vocadb.net/Al/9207"]})
      record = create(model_symbol)
      record.full_update_attributes(attributes)
      expect(record.reload.reference).to eq({:VGMdb => "http://vgmdb.net/album/47999", :vocaloid_DB => "http://vocadb.net/Al/9207"})
    end
    
    it "only updates with valid references" do
      attributes = attributes_for(model_symbol)
      attributes.merge!(reference: {types: ["VGMdb", "vocaloid_DB", "hola"], links: ["http://vgmdb.net/album/47999", "http://vocadb.net/Al/9207", "hiya"]})
      record = create(model_symbol)
      record.full_update_attributes(attributes)
      expect(record.reload.reference).to eq({:VGMdb => "http://vgmdb.net/album/47999", :vocaloid_DB => "http://vocadb.net/Al/9207"})
    end
  end
  
  shared_examples "updates dates properly" do |attribute|
    model_symbol = described_class.model_name
    
    it "saves the date properly and adds a bitmask" do
      record = create(model_symbol)
      attributes = attributes_for(model_symbol)
      attributes.merge!({"#{attribute}(1i)" => "1999",
                         "#{attribute}(2i)" => "",
                         "#{attribute}(3i)" => ""})
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1999, 1, 1))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(6)
    end

    it "saves the date properly and adds a bitmask test 2" do
      record = create(model_symbol)
      attributes = attributes_for(model_symbol)
      attributes.merge!({"#{attribute}(1i)" => "2013",
                         "#{attribute}(2i)" => "5",
                         "#{attribute}(3i)" => ""})
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(2013, 5, 1))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(4)
    end

    it "saves the date properly and adds a bitmask test 3" do
      record = create(model_symbol)
      attributes = attributes_for(model_symbol)
      attributes.merge!({"#{attribute}(1i)" => "",
                         "#{attribute}(2i)" => "5",
                         "#{attribute}(3i)" => "2"})
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1900, 5, 2))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(1)
    end

    it "does not save the date if no attributes are passed in" do
      record = create(model_symbol)
      attributes = attributes_for(model_symbol)
      attributes.merge!({"#{attribute}(1i)" => "",
                         "#{attribute}(2i)" => "",
                         "#{attribute}(3i)" => ""})
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(nil)
      expect(record.reload.send("#{attribute}_bitmask")).to eq(nil)
    end

    it "has a bitmask of 0 with all dates present" do
      record = create(model_symbol)
      attributes = attributes_for(model_symbol)
      attributes.merge!({"#{attribute}(1i)" => "1993",
                         "#{attribute}(2i)" => "8",
                         "#{attribute}(3i)" => "3"})
      record.full_update_attributes(attributes)
      expect(record.reload.send(attribute)).to eq(Date.new(1993,8,3))
      expect(record.reload.send("#{attribute}_bitmask")).to eq(0)
    end
      
  end
  
  shared_examples "updates tag_models" do
    it "updates tag_models"
  end
end
