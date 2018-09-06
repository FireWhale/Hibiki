require 'rails_helper'
require 'cancan/matchers'

describe UserDefaulter do
  let(:params) {attributes_for(:user)}

    it "sets language settings for newly created users" do
      user = UserDefaulter.perform(params)
      user.save
      expect(user.reload.language_settings).to eq([].join(","))
    end

    it "sets artist language settings for newly created users" do
      user = UserDefaulter.perform(params)
      user.save
      expect(user.reload.artist_language_settings).to eq([].join(","))
    end

    it "sets privacy settings for newly created users" do
      user = UserDefaulter.perform(params)
      user.save
      expect(user.reload.privacy).to eq("0")
      expect(user.privacy_settings).to eq([])
    end

    it "sets security settings for newly created users" do
      role = create(:role, name: 'User')
      user = UserDefaulter.perform(params)
      user.save
      expect(user.roles).to match_array([role])
      expect(user.abilities).to match_array(["User", "Any"])
    end

    #Gut check so that new users have a security of 0
    it "has a security of 0 for non-saved users" do
      create(:role, name: 'User')
      user = build(:user)
      expect(user.roles).to be_empty
    end

    it "sets default display settings for newly created users" do
      user = UserDefaulter.perform(params)
      user.save
      expect(user.display_bitmask).to eq(69)
      expect(user.display_settings).to match_array(["Display Limited Editions", "Display Reprints", "Display Ignored"])
    end

    it "initializes with english as a language" do #Maybe set this regionally?
      user = UserDefaulter.perform(params)
      expect(user.language_settings).to eq("")
      expect(user.artist_language_settings).to eq("")
    end

    it "initializes with NWS unchecked" do
      expect(UserDefaulter.perform(params).display_settings).to_not include("Display NWS")
    end

    it "initializes with LEs checked" do
      expect(UserDefaulter.perform(params).display_settings).to include("Display Limited Editions")
    end

    it "initializes with reprints checked" do
      expect(UserDefaulter.perform(params).display_settings).to include("Display Reprints")
    end

    it "initializes with ignored checked" do
      expect(UserDefaulter.perform(params).display_settings).to include("Display Ignored")
    end

    it "initializes with album art border unchecked" do
      expect(UserDefaulter.perform(params).display_settings).to_not include("Outline Album Art")
    end

    it "initializes with bolded AOS unchecked" do
      expect(UserDefaulter.perform(params).display_settings).to_not include("Bold AOS")
    end

    it "initializes with profile, collection, and watchlist unchecked" do
      expect(UserDefaulter.perform(params).privacy_settings).to match_array([])
    end

    it "has the User role before saving" do
      role = create(:role, name: 'User')
      expect(UserDefaulter.perform(params).roles).to match_array([role])
    end

end