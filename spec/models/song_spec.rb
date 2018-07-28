require 'rails_helper'

describe Song do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has the association module"
    include_examples "it is a translated model"
    include_examples "it has images"
    include_examples "it has posts"
    include_examples "it has logs"
    include_examples "it has tags"
    include_examples "it has collections"
    include_examples "it has self-relations"
    include_examples "it can be solr-searched"
    include_examples "it has a custom json method"
    include_examples "it has references"
    include_examples "it has custom pagination"
    include_examples "it has partial dates"

    include_examples "it has form_fields"
  end

  describe "Association Tests" do
    it_behaves_like "it has a primary relation", Source, SongSource
    it_behaves_like "it has a primary relation", Artist, ArtistSong
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute",  :status
    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :track_number, "hi"
    include_examples "is valid with or without an attribute", :disc_number, "hi"
    include_examples "is valid with or without an attribute", :length, 12323
    include_examples "is valid with or without an attribute", :info, "DANCE"
    include_examples "is valid with or without an attribute", :private_info, "DANCE"

    context "does not belong to an album" do
      it "is valid if it does not belong to an album" do
        expect(build(:song, album_id: nil)).to be_valid
      end
    end

    context "belongs to an album" do
      it "is valid if it belongs to an album" do
        expect(build(:song, :with_album)).to be_valid
      end

      it "is not valid if it does not belong to a real album" do
        expect(build(:song, album_id: 99999999)).to_not be_valid
      end
    end
  end

  describe "Attribute Tests" do
    it_behaves_like "it has a serialized attribute", :namehash
  end

  describe "Instance Method Tests" do
    context "op/ed/insert method" do
      SongSource::Relationship.each do |category|
        it "returns #{category} if the song is a #{category}" do
          song = create(:song)
          songsource = create(:song_source, classification: category, song: song)
          expect(song.op_ed_insert).to eq([category])
        end
      end

      it "returns an array if a song is an op and ed" do
        song = create(:song)
        songsource = create(:song_source, song: song, classification: "OP")
        songsource = create(:song_source, song: song, classification: "ED")
        expect(song.op_ed_insert).to match_array(["OP", "ED"])
      end

      it "returns empty if the song is not an op/ed/insert" do
        song = create(:song)
        expect(song.op_ed_insert).to be_empty
        expect(song.op_ed_insert).to be_a Array
      end
    end

    it "returns it's length as time" do
      #The method used is Time.at(x).utc.strf..., so we are doing it manually in the test.
      time = Array(1..999).sample
      song = create(:song, length: time)
      expect(song.length_as_time).to eq("#{time / 60}:#{(time % 60).to_s.rjust(2, '0')}")
    end

    describe "has a disc_track_number method" do
      it "returns a disc and track number" do
        song = create(:song, disc_number: "1", track_number: "10")
        expect(song.disc_track_number).to eq("1.10")
      end

      it "doesn't return a disc number if disc_number is nil" do
        song = create(:song, disc_number: nil, track_number: "10")
        expect(song.disc_track_number).to eq("10")
      end

      it "doesn't return a disc number if disc_number is 0" do
        song = create(:song, disc_number: "0", track_number: "10")
        expect(song.disc_track_number).to eq("10")
      end

      it "doesn't return anything is track number is nil" do
        song = create(:song, disc_number: "1", track_number: nil)
        expect(song.disc_track_number).to eq("")
      end

      it "doesn't returns 0 if track number is 0" do
        song = create(:song, disc_number: "1", track_number: "0")
        expect(song.disc_track_number).to eq("1.00")
      end
    end
  end

  describe "Callbacks/Hooks" do
    describe "Before Save: pull_data_from_album" do
      it "grabs the release_date and release_date_bitmask from the album if present" do
        date = Date.today
        album = create(:album, release_date: date, release_date_bitmask: 3)
        song = create(:song, album: album)
        expect(song.release_date).to eq(date)
        expect(song.release_date_bitmask).to eq(3)
      end

      it "doesn't set a release_date if no album" do
        song = create(:song)
        expect(song.release_date).to be_nil
      end

      it "doesn't set a release_date if no release date on album" do
        album = create(:album, release_date: nil)
        song = create(:song, album: album)
        expect(song.release_date).to be_nil
      end
    end

    describe "Before Save: format_track_number" do
      it "formats tracknumbers into a disc_number and track_number" do
        song = create(:song)
        song.update_attributes(:track_number => "4.39")
        expect(song.track_number).to eq("39")
        expect(song.disc_number).to eq("4")
      end

      it "formats a track number of <10 into a disc_number and track_number" do
        song = create(:song)
        song.update_attributes(:track_number => "4.9")
        expect(song.track_number).to eq("09")
        expect(song.disc_number).to eq("4")
      end
    end

    describe "After Save: manage_sources" do
      include_examples "manages a primary association", Source, SongSource
    end

    describe "After Save: manage_artists" do
      include_examples "manages an artist association"
    end
  end

  describe "Scope Tests" do
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by date range", "release_date"

    it "returns a list of songs with no albums" do
      songlist = create_list(:song, 6, album: nil)
      songlist2 = create_list(:song, 3, :with_album)
      expect(Song.no_album).to eq(songlist)
    end
  end

end


