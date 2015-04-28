require 'rails_helper'

module ScopingTests
  
  shared_examples "filters by a column" do |column, columnlist|
    model_symbol = described_class.model_name.param_key.to_sym
    let(:record1) {create(model_symbol, column.to_sym => columnlist[0])}
    let(:record2) {create(model_symbol, column.to_sym => columnlist[1])}
    let(:record3) {create(model_symbol, column.to_sym => columnlist[1])}
    
    it "returns a result" do
      expect(described_class.send("with_#{column}", columnlist[0])).to eq([record1])
    end
  
    it "returns multiple results" do
      expect(described_class.send("with_#{column}",[columnlist[0], columnlist[1]])).to match_array([record1, record2, record3])
    end
    
    it "returns nothing if no matches" do
      expect(described_class.send("with_#{column}", "Lia")).to eq([])
    end
    
    it "should be an active record relation" do
      expect(described_class.send("with_#{column}", columnlist[0]).class).to_not be_a(Array)
    end
  end
    
  shared_examples "filters by status" do |statuses|
    include_examples "filters by a column", "status", statuses    
  end
  
  shared_examples "filters by category" do |categories|
    include_examples "filters by a column", "category", categories    
  end
  
  shared_examples "filters by activity" do |activities|
    include_examples "filters by a column", "activity", activities   
  end
  
  shared_examples "filters by date range" do |field_name|
    model_symbol = described_class.model_name.param_key.to_sym
    before(:each) do
      if described_class.method_defined?("#{field_name}_bitmask")
        @record1 = create(model_symbol, field_name.to_sym => Date.today, "#{field_name}_bitmask".to_sym => 0)
        @record2 = create(model_symbol, field_name.to_sym => (Date.today - 30), "#{field_name}_bitmask".to_sym => 0)
        @record3 = create(model_symbol, field_name.to_sym => (Date.today - 60), "#{field_name}_bitmask".to_sym => 0)
        @record4 = create(model_symbol, field_name.to_sym => (Date.today - 60), "#{field_name}_bitmask".to_sym => 0)
      else
        @record1 = create(model_symbol, field_name.to_sym => Date.today)
        @record2 = create(model_symbol, field_name.to_sym => (Date.today - 30))
        @record2 = create(model_symbol, field_name.to_sym => (Date.today - 60))
        @record3 = create(model_symbol, field_name.to_sym => (Date.today - 60))
      end
    end
    
    it "filters by date" do
      expect(described_class.in_date_range(Date.today - 5, Date.today + 5)).to match_array([@record1])
    end
    
    it "filters by date" do
      expect(described_class.in_date_range(Date.today - 70, Date.today - 25)).to match_array([@record2, @record3, @record4])
    end
    
    it "can match no dates" do
      expect(described_class.in_date_range(Date.today - 70, Date.today - 61)).to match_array([])     
    end
        
    it "filters by date matches more than one date" do
      expect(described_class.in_date_range(Date.today - 40, Date.today + 5)).to match_array([@record1, @record2])
    end
    
    it "includes dates that are the same start date" do
      expect(described_class.in_date_range(Date.today, Date.today + 5)).to match_array([@record1])
    end
    
    it "includes dates that are the same end date" do
      expect(described_class.in_date_range(Date.today - 5, Date.today)).to match_array([@record1])
    end

    it "includes dates that are the same date" do
      expect(described_class.in_date_range(Date.today, Date.today)).to match_array([@record1])
    end
    
    it "returns no results if end date is before start date" do
      expect(described_class.in_date_range(Date.today + 5, Date.today - 5)).to match_array([])
    end
    
    it "should be an active record relation" do
      expect(described_class.in_date_range(Date.today - 5, Date.today + 5).class).to_not be_a(Array)
    end
  end
  
  shared_examples "filters by security" do
    #Admin class only applies to controller methods. 
    #I think it still filters out security, so this test should always work.
    model_symbol = described_class.model_name.param_key.to_sym
    let(:security1) {(Ability::Abilities - ["Any"]).sample}
    let(:security2) {(Ability::Abilities - [security1, "Any"]).sample}
    let(:security3) {(Ability::Abilities - [security1, security2, "Any"]).sample}
    let(:record1) {create(model_symbol, :visibility => security1)}
    let(:record2) {create(model_symbol, :visibility => security2)}
    let(:record3) {create(model_symbol, :visibility => security2)}
    let(:record4) {create(model_symbol, :visibility => "Any")}
    let(:user1) {create(:user, security: User.get_security_bitmask([security1]))}
    let(:user2) {create(:user, security: User.get_security_bitmask([security2]))}
    let(:user3) {create(:user, security: User.get_security_bitmask([security1, security2]))}
    
    it "should return if it matches the security" do
      expect(described_class.meets_security(user1)).to match_array([record1, record4])
    end
    
    it "should return if it matches the security 2" do
      expect(described_class.meets_security(user2)).to match_array([record2, record3, record4])
    end
    
    it "should take handle multiple securities" do
      expect(described_class.meets_security(user3)).to match_array([record1, record2, record3, record4])
    end
    
    it "should take a nil user, but only returns records with 'Any' Security" do
      expect(described_class.meets_security(nil)).to match_array([record4])
    end
    
    it "should be an active record relation" do
      expect(described_class.meets_security(user1).class).to_not be_a(Array)
    end
    
  end
  
  shared_examples "filters by tag" do
    model_symbol = described_class.model_name.param_key.to_sym
    let(:tag1) {create(:tag)}
    let(:tag2) {create(:tag)}
    let(:tag3) {create(:tag)}
    let(:tag4) {create(:tag)}
    let(:record1) {create(model_symbol)} #tags 1
    let(:record2) {create(model_symbol)} #tags 1 and 2
    let(:record3) {create(model_symbol)} #tags 2 and 3
    let(:record4) {create(model_symbol)} #no tags
    before(:each) do
      create(:taglist, subject: record1, tag: tag1)
      create(:taglist, subject: record2, tag: tag1)
      create(:taglist, subject: record2, tag: tag2)
      create(:taglist, subject: record3, tag: tag2)
      create(:taglist, subject: record3, tag: tag3)
    end
        
    it "filters by tag" do
      expect(described_class.with_tag(tag1.id)).to match_array([record1, record2])
    end
    
    it "filters by tag 2" do
      expect(described_class.with_tag(tag3.id)).to match_array([record3])
    end
    
    it "accepts multiple tags" do
      expect(described_class.with_tag([tag2.id, tag3])).to match_array([record2, record3])
    end
    
    it "returns nothing if the tag is not used" do
      expect(described_class.with_tag(tag4.id)).to eq([])
    end
    
    it "should return everything if no tag_id is specified" do
      expect(described_class.with_tag(nil)).to match_array([record1, record2, record3, record4])
    end

    it "should be an active record relation" do
      expect(described_class.with_tag(tag1.id).class).to_not be_a(Array)
    end
  end
  
  shared_examples "filters by self relation categories" do
    model_symbol = described_class.model_name.param_key.to_sym
    join_table_class = "Related#{described_class.to_s}s".constantize
    join_table_symbol = join_table_class.model_name.param_key.to_sym    
    unless described_class == Artist
      relationships = described_class.const_get("SelfRelationships").map { |relation| relation[3]}.reject(&:nil?)
    else
      relationships = described_class.const_get("SelfRelationships").reject {|r| r.count < 3}.map(&:last)
    end
    let(:record1) {create(model_symbol)}
    let(:record2) {create(model_symbol)} #limited edition of 1
    let(:record3) {create(model_symbol)} #limited edition of 1
    let(:record4) {create(model_symbol)} #reprint of 1
    let(:record5) {create(model_symbol)} #reprint of 4 and LE of 3
    let(:record6) {create(model_symbol)} 
    let(:relationship1) {relationships.sample}
    let(:relationship2) {(relationships - [relationship1]).sample}
    let(:relationship3) {(relationships - [relationship1, relationship2]).sample}
    before(:each) do
      create(join_table_symbol, "#{model_symbol}1".to_sym => record2, "#{model_symbol}2".to_sym => record1, category: relationship1)
      create(join_table_symbol, "#{model_symbol}1".to_sym => record3, "#{model_symbol}2".to_sym => record1, category: relationship1)
      create(join_table_symbol, "#{model_symbol}1".to_sym => record4, "#{model_symbol}2".to_sym => record1, category: relationship2)
      create(join_table_symbol, "#{model_symbol}1".to_sym => record5, "#{model_symbol}2".to_sym => record4, category: relationship2)
      create(join_table_symbol, "#{model_symbol}1".to_sym => record5, "#{model_symbol}2".to_sym => record3, category: relationship1)
    end
    
    describe "Has a category" do
      it "filters by a category" do
        expect(described_class.with_self_relation_categories(relationship1)).to match_array([record2, record3, record5])
      end
      
      it "filters by multiple categories" do
        expect(described_class.with_self_relation_categories([relationship1, relationship2])).to match_array([record2, record3, record4, record5])
      end
      
      it "returns nothing if there are no matches" do
        expect(described_class.with_self_relation_categories(["yo"])).to match_array([])
      end
      
      it "matches on any category" do
        expect(described_class.with_self_relation_categories(relationship2)).to match_array([record4, record5])        
      end
      
      it "returns all records if nil is passed in" do
        expect(described_class.with_self_relation_categories(nil)).to match_array([record1, record2, record3, record4, record5, record6])        
      end
      
      it "should be an active record relation" do
        expect(described_class.with_self_relation_categories(relationship1).class).to_not be_a(Array)
      end
    end
    
    describe "does not have a category" do
      it "filters by removing records with a certain category" do
        expect(described_class.without_self_relation_categories(relationship1)).to match_array([record1, record4, record6])
      end
      
      it "filters by removing records with a certain multiple categories" do
        expect(described_class.without_self_relation_categories([relationship1, relationship2])).to match_array([record1, record6])
      end
      
      it "filters by removing records matching on either category" do
        expect(described_class.without_self_relation_categories(relationship2)).to match_array([record1, record2, record3, record6])        
      end
      
      it "returns all records if nil is passed in"  do
        expect(described_class.without_self_relation_categories(nil)).to match_array([record1, record2, record3, record4, record5, record6])        
      end
      
      it "should be an active record relation" do
        expect(described_class.without_self_relation_categories("hi").class).to_not be_a(Array)
      end
    end
          
          
    describe "does have a cateogy and does not have others" do
      it "returns records that matches either filter" do
        expect(described_class.filters_by_self_relation_categories([relationship1], "hey!")).to match_array([record1, record2, record3, record4, record5, record6])                
      end
      
      it "returns records that match the filter" do
        expect(described_class.filters_by_self_relation_categories([relationship1], relationship2)).to match_array([record1, record2, record3, record5, record6])         
      end

      it "returns records that match the filter 2" do
        expect(described_class.filters_by_self_relation_categories([relationship2], relationship1)).to match_array([record1, record4, record5, record6])         
      end
      
      it "returns all records if nil is passed into both" do
        expect(described_class.filters_by_self_relation_categories(nil, nil)).to match_array([record1, record2, record3, record4, record5, record6])           
      end
      
      it "filters out as much as posssible" do
        expect(described_class.filters_by_self_relation_categories("hi", [relationship1, relationship2])).to match_array([record1, record6])           
      end
      
      it "returns all records if the same category is passed into both params" do
        expect(described_class.filters_by_self_relation_categories([relationship1], relationship1)).to match_array([record1, record2, record3, record4, record5, record6])       
      end
      
      it "should be an active record relation" do
        expect(described_class.filters_by_self_relation_categories("hey", "hi").class).to_not be_a(Array)
      end
    end
    
  end 
  
  shared_examples "filters by watchlist" do
    describe "filters by watchlist" do
      model_symbol = described_class.model_name.param_key.to_sym
      let(:record1) {create(model_symbol)}
      let(:record2) {create(model_symbol)}
      let(:record3) {create(model_symbol)}
      let(:record4) {create(model_symbol)}
      let(:user1) {create(:user)} #watches artist1
      let(:user2) {create(:user)} #watches artist2 and artist3
      let(:user3) {create(:user)} #watches artist3
      let(:user4) {create(:user)} #watches nothing
      before(:each) do
        create(:watchlist, user: user1, watched: record1)
        create(:watchlist, user: user2, watched: record2)
        create(:watchlist, user: user2, watched: record3)
        create(:watchlist, user: user3, watched: record3)
      end
      
      it "filters by watchlist" do
        expect(described_class.watched_by(user1.id)).to match_array([record1])
      end
      
      it "matches on multiple user_ids" do
        expect(described_class.watched_by([user1.id, user2.id])).to match_array([record1,record2,record3])
      end
      
      it "does not duplicate records" do
        expect(described_class.watched_by([user3.id, user2.id])).to match_array([record2,record3])        
      end
      
      it "can return nothing" do
        expect(described_class.watched_by(user4.id)).to match_array([])
      end
      
      it "returns all if nil is passed in" do
        expect(described_class.watched_by(nil)).to match_array([record1,record2,record3,record4])
      end      
      
      it "should be an active record relation" do
        expect(described_class.watched_by(user1.id).class).to_not be_a(Array)
      end
    end
  end
end
