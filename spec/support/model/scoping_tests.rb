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
    let(:user1) {create(:user)}
    let(:user2) {create(:user)}
    let(:user3) {create(:user)}
    
    before(:each) do
      user1.update_attribute(:security, User.get_security_bitmask([security1]))
      user2.update_attribute(:security, User.get_security_bitmask([security2]))
      user3.update_attribute(:security, User.get_security_bitmask([security1, security2]))
    end
    
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
  
end
