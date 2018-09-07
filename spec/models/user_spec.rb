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
        role1 = create(:role, name: 'Admin')
        role3 = create(:role, name: 'User')
        user.roles << role1
        user.roles << role3
        expect(user.abilities).to eq(["Admin","User", "Any"])
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

  end

end


