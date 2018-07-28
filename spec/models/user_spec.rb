require 'rails_helper'
require 'cancan/matchers'

describe User do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has a custom json method"
    include_examples "it has images"
    include_examples "it has references"
    include_examples "it has custom pagination"
  end

  describe "Association Tests" do
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

  end

  describe "Instance Method Tests" do
    it "sends off a password reset email" do
      user = create(:user)
      expect{user.deliver_password_reset_instructions!}.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "resets the perishable token when reseting password" do
      user = create(:user)
      expect(user).to receive(:reset_perishable_token!)
      user.deliver_password_reset_instructions!
    end

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
    describe "Before Validation on create: set_default_settings" do
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

      it "initializes with english as a language" do #Maybe set this regionally?
        expect(create(:user).language_settings).to eq("")
        expect(create(:user).artist_language_settings).to eq("")
      end

      it "initializes with NWS unchecked" do
        expect(create(:user).display_settings).to_not include("Display NWS")
      end

      it "initializes with LEs checked" do
        expect(create(:user).display_settings).to include("Display Limited Editions")
      end

      it "initializes with reprints checked" do
        expect(create(:user).display_settings).to include("Display Reprints")
      end

      it "initializes with ignored checked" do
        expect(create(:user).display_settings).to include("Display Ignored")
      end

      it "initializes with album art border unchecked" do
        expect(create(:user).display_settings).to_not include("Outline Album Art")
      end

      it "initializes with bolded AOS unchecked" do
        expect(create(:user).display_settings).to_not include("Bold AOS")
      end

      it "initializes with profile, collection, and watchlist unchecked" do
        expect(create(:user).privacy_settings).to match_array([])
      end

      it "has User, Any as it's security" do
        expect(create(:user).abilities).to match_array(["User", "Any"])
      end

      it "only sets security on create" do
        user = create(:user)
        user.security = "5"
        user.save
        expect(user.reload.security).to eq("5")
      end
    end

    describe "Before Save: manage_profile_settings" do
      let(:user) {create(:user, name: "ronny")}

      it "updates display_settings" do
        user.display_form_settings = ["Display Limited Editions", "Bold AOS", "Edit Mode", "Display Reprints"]
        user.save
        expect(user.reload.display_bitmask).to eq(113)
      end

      it "updates privacy_settings" do
        user.privacy_form_settings =  ["Show Collection"]
        user.save
        expect(user.reload.privacy).to eq("2")
      end

      it "updates language_settings" do
        user.language_form_settings = ["english", "korean", "japanese"]
        user.save
        expect(user.reload.language_settings).to eq("english,korean,japanese")
      end

      it "updates artist_language_settings" do
        user.artist_language_form_settings = ["english", "korean", "japanese"]
        user.save
        expect(user.reload.artist_language_settings).to eq("english,korean,japanese")
      end

      it "does not update display bitmask to 0 if no display_settings key" do
        user.update_attribute(:display_bitmask, 5)
        user.save
        expect(user.reload.display_bitmask).to eq(5)
      end

      it "does not update privacy bitmask to 0 if no privacy_settings key" do
        user.update_attribute(:privacy, "3")
        user.save
        expect(user.reload.privacy).to eq("3")
      end

      it "does not update languages settings if no language key"  do
        user.update_attribute(:language_settings, "english,korean,japanese")
        user.save
        expect(user.reload.language_settings).to eq("english,korean,japanese")
      end

      it "filters out none valid languages" do
        user.language_form_settings = ["hiya!"]
        user.save
        expect(user.reload.language_settings).to_not eq("hiya!")
      end

      it "does not update artist languages settings if no language key"  do
        user.update_attribute(:artist_language_settings, "english,korean,japanese")
        user.save
        expect(user.reload.artist_language_settings).to eq("english,korean,japanese")
      end

      it "filters out none valid languages (for artists)" do
        user.artist_language_form_settings = ["hiya!"]
        user.save
        expect(user.reload.artist_language_settings).to_not eq("hiya!")
      end
    end

    describe "Before Save: manage_security_settings" do
      it "can update_security" do
        user = create(:user)
        user.security_array = ["User", "Blogger", "Scraper"]
        user.save
        expect(user.reload.security).to eq("50")
      end

      it "does not update security to 0 if values[:abilities] is nil" do
        user = create(:user, name: "haha")
        user.save
        expect(user.reload.security).to_not eq("0")
      end

      it "accepts only valid securities in update_security" do
        user = create(:user, name: "haha")
        user.security_array = ["User", "Blogger", "Scraper", "haha", "hoho"]
        user.save
        expect(user.reload.security).to eq("50")
      end
    end

  end

end


