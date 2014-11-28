require 'rails_helper'

describe Lyric do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:lyric)
      expect(instance).to be_valid
    end
    
  #Association Test
    it "belongs to a song" do
      expect(create(:lyric).song).to be_a Song
      expect(Lyric.reflect_on_association(:song).macro).to eq(:belongs_to)
    end
    
    it "does not destroy the song when destroyed" do
      lyric = create(:lyric)
      expect{lyric.destroy}.to change(Song, :count).by(0)
    end
    
  #Validation Tests      
    include_examples "is invalid without an attribute", :lyric, :language
    include_examples "is invalid without an attribute", :lyric, :lyrics

    it "is invalid without a song" do
      expect(build(:lyric, song: nil)).not_to be_valid
    end
    
    it "is invalid without a real song" do
      expect(build(:lyric, song_id: 9999999)).to_not be_valid
    end
    
    it "is invalid with duplicate language/song combinations" do
      song = create(:song)
      create(:lyric, song: song, language: "English")
      expect(build(:lyric, song: song, language: "English")).to_not be_valid
    end
      
end


