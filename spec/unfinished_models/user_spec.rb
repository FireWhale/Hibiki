require 'rails_helper'
require 'cancan/matchers'

describe User do
  include_examples "global model tests" #Global Tests
    
  describe "Association Tests" do
    it_behaves_like "it has images"
    
    it "has many collections"
    it "has many watchlists"    
      
  end
  
  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :email  
    
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

    include_examples "is invalid without an attribute in a category", :security, Array(1..(2**Ability::Abilities.count - 1)).map(&:to_s), "Security bitmask"
    
    include_examples "is valid with or without an attribute", :profile, "hi"
    include_examples "is valid with or without an attribute", :sex, "73"
    include_examples "is valid with or without an attribute", :privacy, "hi"
    include_examples "is valid with or without an attribute", :usernames, "hi"
    include_examples "is valid with or without an attribute", :display_bitmask, "hi"
    include_examples "is valid with or without an attribute", :language_settings, "hi"
    include_examples "is valid with or without an attribute", :artist_language_settings, "hi"
  
    it_behaves_like "it has a partial date", :birth_date
  end
      
  describe "Authentication Tests" do
    it "acts as authentic"
  end
    
  describe "Instance Method Tests" do
    it "can update_profile"
    
    it "can update_security"
    
    it "can send a password reset form"
    
    it "can send a user_confirmation email"
    #it needs to be confirmed to add watchlists/collections? Maybe in the future
    
    describe "get data" do
      it "can get display_settings"
      
      it "can get abilities"
      
      it "can get album/song filter" do
        #It returns an array of categories to filter out
        #parsed from display_settings
      end
    end  
  end
  describe "Class Method Tests" do  
    it "can get a security_bitmask"
  end
    
  #Scope Tests
    
    
  #Other Tests?
    #Pagination?
    #Delete images method?
end


