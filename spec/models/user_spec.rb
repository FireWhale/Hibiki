require 'rails_helper'
require 'cancan/matchers'

describe User do
  include_examples "global model tests" #Global Tests
  
  describe "Module Tests" do
    it_behaves_like "it has pagination"
    it_behaves_like "it has a custom json method"
  end
  
  describe "Association Tests" do
    it_behaves_like "it has images"
    it_behaves_like "it is a polymorphically-linked class", Collection, [Album, Song], "collected"
    it_behaves_like "it is a polymorphically-linked class", Watchlist, [Artist, Organization, Source], "watched"      
  end
  
  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :email  
    
    it "is invalid with a short password" do
      expect(build(:user, password: "hi", password_confirmation: "hi")).to_not be_valid
    end
    
    it "is invalid with the username in the password" do
      expect(build(:user, name: "hohoh", password: "hohohoho1", password_confirmation: "hohohoho1")).to_not be_valid      
    end
    
    it "is invalid without an crypted_password" do
      expect(build(:user, :crypted_password => nil)).not_to be_valid  
      expect(build(:user, :crypted_password => "")).to_not be_valid  
    end

    it "is invalid without an password_salt" do
      expect(build(:user, :password_salt => nil)).not_to be_valid  
      expect(build(:user, :password_salt => "")).to_not be_valid  
    end

    it "is invalid without a security" do
      user = create(:user)
      user.send(:security=, nil)
      expect(user).to_not be_valid      
    end
    
    it "is invalid with an empty security" do
      user = create(:user)
      user.send(:security=, "")
      expect(user).to_not be_valid      
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
        input = {display_settings: ["Display Limited Editions", "Bold AOS", "Edit Mode", "Display Reprints"]}
        user.update_profile(input)
        expect(user.reload.display_bitmask).to eq(113)
      end
      
      it "updates privacy_settings" do
        input = {privacy_settings: ["Show Collection"]}
        user.update_profile(input)
        expect(user.reload.privacy).to eq("2")        
      end
      
      it "updates language_settings" do
        input = {language_settings: ["english", "korean", "japanese"]}
        user.update_profile(input)
        expect(user.reload.language_settings).to eq("english,korean,japanese")
      end

      it "updates artist_language_settings" do
        input = {artist_language_settings: ["english", "korean", "japanese"]}
        user.update_profile(input)
        expect(user.reload.artist_language_settings).to eq("english,korean,japanese")
      end

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
      
      it "does not update languages settings if no language key"  do
        user.update_attribute(:language_settings, "english,korean,japanese")
        input = {hwoefhewoifhe: ["hiya!"]}
        user.update_profile(input)
        expect(user.reload.language_settings).to eq("english,korean,japanese")
      end
      
      it "filters out none valid languages" do
        input = {language_settings: ["hiya!"]}
        user.update_profile(input)
        expect(user.reload.language_settings).to_not eq("hiya!")
      end
      
      it "does not update artist languages settings if no language key"  do
        user.update_attribute(:artist_language_settings, "english,korean,japanese")
        input = {hwoefhewoifhe: ["hiya!"]}
        user.update_profile(input)
        expect(user.reload.artist_language_settings).to eq("english,korean,japanese")
      end
      
      it "filters out none valid languages (for artists)" do
        input = {artist_language_settings: ["hiya!"]}
        user.update_profile(input)
        expect(user.reload.artist_language_settings).to_not eq("hiya!")
      end
      
      it "filters out other values" do
        input = {name: "ronny"}
        user.update_profile(input)
        expect(user.reload.name).to eq("ronny")        
      end
      
      it "returns false if there are no valid attributes being updated" do
        input = {name: "ronny"}
        user.update_profile(input)
        expect(user.update_profile(input)).to eq(false)
      end
    end

    describe "can update_security" do
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
      
      it "returns false if ther eare no valid attributes" do
        user = create(:user, name: "haha")
        input = {:name => 'hey'}
        expect(user.update_security(input)).to eq(false)
      end
    end
    
    it "sends off a password reset email" do
      user = create(:user)
      expect{user.deliver_password_reset_instructions!}.to change(ActionMailer::Base.deliveries, :count).by(1)              
    end
    
    it "resets the perishable token when reseting password" do
      user = create(:user)
      expect(user).to receive(:reset_perishable_token!)
      user.deliver_password_reset_instructions!      
    end
    
    it "can send a user_confirmation email"
    #it needs to be confirmed to add watchlists/collections? Maybe in the future
    
    describe "get data" do
      it "can get display_settings" do
        user = create(:user)
        user.update_attribute(:display_bitmask, 115)
        expect(user.display_settings).to eq(["Display Limited Editions","Display NWS","Bold AOS","Edit Mode", "Display Reprints"])
      end
      
      it "can get abilities" do
        user = create(:user)
        user.update_attribute(:security, 45)
        expect(user.abilities).to eq(["Admin","Confident","Database Manager", "Scraper", "Any"])
      end
      
      it "can get privacy_settings" do
        user = create(:user)
        user.update_attribute(:privacy, 3)
        expect(user.privacy_settings).to eq(["Show Watchlist", "Show Collection"])
      end
      
      it "can get album/song filter" do
        user = create(:user)
        user.update_attribute(:display_bitmask, 74)
        expect(user.album_filter).to eq(["Limited Edition", "Ignored"])
      end
    end  
  end
  
  describe "Class Method Tests" do  
    it "can get a security_bitmask" do
      expect(User.get_security_bitmask(["User", "Database Manager", "hi", "Scraper"])).to eq(42)
    end
    
    it "can get a display_bitmask" do
      expect(User.get_display_bitmask(["Display NWS", "hoho", "Display Ignored", "Outline Album Art"])).to eq(14)
    end
    
    it "can get a privacy_bitmask" do
      expect(User.get_privacy_bitmask(["Show Watchlist"])).to eq(1)      
    end
    
    it "can get language_settings" do
      expect(User.get_language_settings(["hi", "english", "korean", "hoho"])).to eq("english,korean")
    end
    
    it "removes duplicates from langauge_settings" do
      expect(User.get_language_settings(["hi", "english", "english", "korean", "english", "hoho"])).to eq("english,korean")
    end
  end
    
  describe "Callback Tests" do
    it "sets language settings for newly created users" do
      user = build(:user)
      user.save
      expect(user.reload.language_settings).to eq([].join(","))
    end
    
    it "sets artist language settings for newly created users" do
      user = build(:user)
      user.save
      expect(user.reload.artist_language_settings).to eq([].join(","))      
    end
    
    it "sets privacy settings for newly created users" do
      user = build(:user)
      user.save
      expect(user.reload.privacy).to eq("0")
      expect(user.privacy_settings).to eq([])
    end
    
    it "sets security settings for newly created users" do
      user = build(:user)
      user.save
      expect(user.reload.security).to eq("2")
      expect(user.abilities).to match_array(["User", "Any"])
    end
    
    #Gut check so that new users have a security of 0
    it "has a security of 0 for non-saved users" do
      user = build(:user)
      expect(user.security).to eq(nil)
    end
    
    it "sets default display settings for newly created users" do
      user = build(:user)
      user.save
      expect(user.display_bitmask).to eq(69)
      expect(user.display_settings).to match_array(["Display Limited Editions", "Display Reprints", "Display Ignored"])
    end
    
    it "does not set any params using save" do
      user = create(:user)
      user.security = "5"
      user.save
      expect(user.reload.security).to eq("5")
    end
  end
    
  #Scope Tests
    
end


