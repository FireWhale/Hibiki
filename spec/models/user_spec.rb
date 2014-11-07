require 'rails_helper'

describe User do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:user)
      expect(instance).to be_valid
    end
    
  #Association tests
    it "has many collections"
    it "has many watchlists"
    it "has many Ratings"
    it "has many IssueUsers"
    it_behaves_like "it has images", :artist, Artist
    it "has many posts as user"
    it "has many posts as recipient"
      
  #Validation Tests
    include_examples "is invalid without an attribute", :user, :name
    include_examples "is invalid without an attribute", :user, :email  
    
    it "is invalid without an crypted_password" do
      expect(build(:user, :crypted_password => nil)).not_to be_valid  
      expect(build(:user, :crypted_password => "")).to_not be_valid  
    end

    it "is invalid without an password_salt" do
      expect(build(:user, :password_salt => nil)).not_to be_valid  
      expect(build(:user, :password_salt => "")).to_not be_valid  
    end

    it "is invalid without an security" do
      expect(build(:user, :security => nil)).not_to be_valid  
      expect(build(:user, :security => "")).to_not be_valid  
    end

    include_examples "is invalid without an attribute in a category", :user, :security, Array(1..(2**Ability::Abilities.count - 1)).map(&:to_s), "Security bitmask"
    
    include_examples "is valid with or without an attribute", :user, :profile, "hi"
    include_examples "is valid with or without an attribute", :user, :sex, "73"
    include_examples "is valid with or without an attribute", :user, :privacy, "hi"
    include_examples "is valid with or without an attribute", :user, :usernames, "hi"
    include_examples "is valid with or without an attribute", :user, :display_bitmask, "hi"
    include_examples "is valid with or without an attribute", :user, :language_settings, "hi"
    include_examples "is valid with or without an attribute", :user, :artist_language_settings, "hi"
  
    it_behaves_like "it has a partial date", :user, :birth_date
      
  #Serialization Tests
    #None
    
  #Instance Method Tests
    it "can update_profile"
    
    it "can update_security"
  
  #Class Method Tests    
    
    
    
  #Scope Tests
    
    
  #Other Tests?
    #Pagination?
    #Delete images method?
end


