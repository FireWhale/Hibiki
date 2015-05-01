require 'rails_helper'
require 'cancan/matchers'

describe User do
  include_examples "global model tests" #Global Tests
    
  describe "Association Tests" do
    it_behaves_like "it has images"
    it_behaves_like "it is a polymorphically-linked class", Collection, [Album, Song], "collected"
    it_behaves_like "it is a polymorphically-linked class", Watchlist, [Artist, Organization, Source], "watched"      
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
      
  describe "Ability Tests" do
    context "Admin" do
      it "has abilities" #oh god the tests here
    end
  end
    
  describe "Instance Method Tests" do
    describe "can update_profile" do
      #accepts display settings, privacy settings, and language settings
      let(:user) {create(:user, name: "ronny")}
      
      it "updates display_settings" do
        input = {display_settings: ["DisplayLEs", "BoldAOS", "BoldForEditing", "DisplayReprints"]}
        user.update_profile(input)
        expect(user.reload.display_bitmask).to eq(113)
      end
      
      it "updates privacy_settings" do
        input = {privacy_settings: ["ShowCollection"]}
        user.update_profile(input)
        expect(user.reload.privacy).to eq("2")        
      end
      
      it "updates language_settings"

      it "does not update display bitmask to 0 if no display_settings key" do
        user.update_attribute(:display_bitmask, 5)
        input = {privacy_settings: ["ShowCollection"]}
        user.update_profile(input)
        expect(user.reload.display_bitmask).to eq(5)    
      end
      
      it "does not update privacy bitmask to 0 if no privacy_settings key" do
        user.update_attribute(:privacy, "3")
        input = {hihi: ["ShowCollection"]}
        user.update_profile(input)
        expect(user.reload.privacy).to eq("3")        
      end
      
      it "does not update languages settings if no language key"

      it "filters out other values" do
        input = {name: "ronny"}
        user.update_profile(input)
        expect(user.reload.name).to eq("ronny")        
      end
    end

    it "can update_security" do
      user = create(:user)
      input = {:abilities => ["User", "Blogger", "Scraper"]}
      user.update_security(input)
      expect(user.reload.security).to eq("50")
    end
    
    it "does not update security to 0 if values[:abilities] is nil" do
      user = create(:user, name: "haha")
      input = {:name => 'hey'}
      user.update_security(input)
      expect(user.reload.security).to_not eq("0")      
    end
    
    it "accepts only security in update_security" do
      user = create(:user, name: "haha")
      input = {:abilities => ["User", "Blogger", "Scraper"], :name => "hi"}
      user.update_security(input)
      expect(user.reload.name).to eq("haha")
    end
    
    it "can send a password reset form"
    
    it "can send a user_confirmation email"
    #it needs to be confirmed to add watchlists/collections? Maybe in the future
    
    describe "get data" do
      it "can get display_settings" do
        user = create(:user, display_bitmask: 115)
        expect(user.display_settings).to eq(["DisplayLEs","DisplayNWS","BoldAOS","BoldForEditing", "DisplayReprints"])
      end
      
      it "can get abilities" do
        user = create(:user, security: 45)
        expect(user.abilities).to eq(["Admin","Confident","Database Manager", "Scraper", "Any"])
      end
      
      it "can get album/song filter" do
        user = create(:user, display_bitmask: 74)
        expect(user.album_filter).to eq(["Limited Edition", "Ignored"])
      end
    end  
  end
  
  describe "Class Method Tests" do  
    it "can get a security_bitmask" do
      expect(User.get_security_bitmask(["User", "Database Manager", "hi", "Scraper"])).to eq(42)
    end
    
    it "can get a display_bitmask" do
      expect(User.get_display_bitmask(["DisplayNWS", "hoho", "DisplayIgnored", "OutlineAlbumArt"])).to eq(14)
    end
    
    it "can get a privacy_bitmask" do
      expect(User.get_privacy_bitmask(["ShowWatchlist"])).to eq(1)      
    end
  end
    
  #Scope Tests
    
    
  #Other Tests?
    #Pagination?
    #Delete images method?
end


