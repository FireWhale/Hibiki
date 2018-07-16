require 'rails_helper'


describe Album do
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
    include_examples "it has a primary relation", Artist, ArtistAlbum
    include_examples "it has a primary relation", Organization, AlbumOrganization
    include_examples "it has a primary relation", Source, AlbumSource
    include_examples "it has_many through", Event, AlbumEvent, :with_album_event

    describe "it has a relationship with songs" do
      it "has many songs" do
        expect(create(:album, :with_songs).songs.first).to be_a Song
        expect(Album.reflect_on_association(:songs).macro).to eq(:has_many)
      end

      it "destroys it's songs when destroyed" do
        album = create(:album, :with_song)
        expect{album.destroy}.to change(Song, :count).by(-1)
      end

      it "is valid with songs" do
        album = create(:album)
        list = create_list(:song, 5, album: album)
        expect(album.songs).to match_array(list)
      end

      it "is valid without songs" do
        #well the factory doesn't come with songs
        expect(create(:album)).to be_valid
      end
    end
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :status
    include_examples "is invalid without an attribute", :catalog_number

    it "is invalid with a duplicate name/release_date/catalog combination" do
      create(:album, :release_date => Date.today, :release_date_bitmask => 5, :internal_name => "hi", :catalog_number => "hihi")
      expect(build(:album, :release_date => Date.today, :release_date_bitmask => 5, :internal_name => "hi", :catalog_number => "hihi")).to_not be_valid
    end

    it "is valid with duplicate catalog_numbers" do
      expect(create(:album, catalog_number: "hihi")).to be_valid
      expect(build(:album, catalog_number: "hihi")).to be_valid
    end

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :classification, "classification!"
  end

  describe "Attribute Tests" do
    include_examples "it has a partial date", :release_date
    it_behaves_like "it has a serialized attribute", :namehash
  end

  describe "Callbacks/Hooks" do
    describe "After Save: manage_events" do
      include_examples "manages a primary association", Event, AlbumEvent
    end

    describe "After Save: manage_organizations" do
      include_examples "manages a primary association", Organization, AlbumOrganization
    end

    describe "After Save: manage_artists" do
      include_examples "manages an artist association"
    end

    describe "After Save: manage_sources" do
      include_examples "manages a primary association", Source, AlbumSource
    end

    describe "After Save: manage_songs" do
      it "adds new songs" do
        album = create(:album)
        album.new_songs = {:internal_name => ["hi"], :status => ["Released"]}
        expect{album.save}.to change(Song, :count).by(1)
      end

      it "adds multiple songs" do
        album = create(:album)
        album.new_songs = {:internal_name => ["hi", "ho", "he"], :status => ["Unreleased", "Released", "Private"]}
        expect{album.save}.to change(Song, :count).by(3)
      end

      it "adds multiple song attributes" do
        album = create(:album)
        attributes1 = attributes_for(:song, :full_attributes)
        attributes2 = attributes_for(:song, :full_attributes)
        params = attributes1.inject({}) { |h,(k,v)| h[k] = [v]; h }
        attributes2.each {|k,v| params[k] << v }
        album.new_songs = params
        expect{album.save}.to change(Song, :count).by(2)
        #Changing some attributes to fit the form of the actual record
        attributes1[:length] = attributes1[:length].to_i
        attributes2[:length] = attributes2[:length].to_i
        expect(album.songs.first).to have_attributes(attributes1)
        expect(album.songs[1]).to have_attributes(attributes2)
      end
    end
  end

  describe "Instance Method Tests" do
    describe "returns the right week/month/year" do
      let(:album) {create(:album, release_date: Date.today, release_date_bitmask: 6)}

      it "returns the right week" do
        expect(album.week).to eq(Date.today.beginning_of_week(:sunday))
      end

      it "takes in a different starting day for the week" do
        expect(album.week("monday")).to eq(Date.today.beginning_of_week(:monday))
      end

      it "returns the right month" do
        expect(album.month).to eq(Date.today.beginning_of_month)
      end

      it "returns the right year" do
        expect(album.year).to eq(Date.today.beginning_of_year)
      end

      it "returns nil if there is no release_date" do
        album_no_date = create(:album, release_date: nil)
        expect(album_no_date.week).to be_nil
        expect(album_no_date.month).to be_nil
        expect(album_no_date.year).to be_nil
      end
    end

    describe "tests for certain self_relations" do
      it "responds to limited_edition?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Limited Edition")
        expect(album.limited_edition?).to be_truthy
        expect(album2.limited_edition?).to be_falsey
      end

      it "responds to reprint?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Reprint")
        expect(album.reprint?).to be_truthy
        expect(album2.reprint?).to be_falsey
      end

      it "responds to alternate_printing?" do
        album = create(:album)
        album2 = create(:album)
        related_album = create(:related_albums, album1: album, album2: album2, category: "Alternate Printing")
        expect(album.alternate_printing?).to be_truthy
        expect(album2.alternate_printing?).to be_falsey
      end
    end
  end

  describe "Scope Tests" do
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by date range", "release_date"

    describe "filters by AOS" do
      let(:album1) {create(:album)}
      let(:album2) {create(:album)}
      let(:album3) {create(:album)}
      let(:album4) {create(:album)}

      ["artist", "source", "organization"].each do |model|
        describe "by #{model}" do
          join_table_symbol = (model == "artist" ? :artist_album : "album_#{model}".to_sym)
          let(:record1) {create(model.to_sym)} #album1, album2
          let(:record2) {create(model.to_sym)} #album1
          let(:record3) {create(model.to_sym)} #album2
          let(:record4) {create(model.to_sym)} #album3
          let(:record5) {create(model.to_sym)}
          before(:each) do
            create(join_table_symbol, album: album1, model.to_sym => record1)
            create(join_table_symbol, album: album1, model.to_sym => record2)
            create(join_table_symbol, album: album2, model.to_sym => record1)
            create(join_table_symbol, album: album2, model.to_sym => record3)
            create(join_table_symbol, album: album3, model.to_sym => record4)
          end

          it "filters by #{model}_id" do
            expect(Album.send("with_#{model}",record1.id)).to match_array([album1,album2])
          end

          it "matches on several ids" do
            expect(Album.send("with_#{model}",[record2.id, record4.id])).to match_array([album1,album3])
          end

          it "does not duplicate an album if it matches several times" do
            expect(Album.send("with_#{model}",[record2.id, record1.id])).to match_array([album1,album2])
          end

          it "can match on nothing" do
            expect(Album.send("with_#{model}",record5.id)).to match_array([])
          end

          it "returns all records if nil is passed in" do
            expect(Album.send("with_#{model}",nil)).to match_array([album1,album2,album3,album4])
          end

          it "returns an active record relation" do
            expect(Album.send("with_#{model}",record5.id).class).to_not be_a(Array)
          end
        end

      end

      describe "filters by artists, sources, and organizations" do
        let(:artist1) {create(:artist)} #album1, #album2
        let(:artist2) {create(:artist)} #album3
        let(:organization1) {create(:organization)} #album4
        let(:organization2) {create(:organization)} #album 2
        let(:organization3) {create(:organization)}
        let(:source1) {create(:source)} #album2
        let(:source2) {create(:source)} #album3, album4
        before(:each) do
          create(:artist_album, album: album1, artist: artist1)
          create(:artist_album, album: album2, artist: artist1)
          create(:artist_album, album: album3, artist: artist2)
          create(:album_organization, album: album2, organization: organization2)
          create(:album_organization, album: album4, organization: organization1)
          create(:album_source, album: album2, source: source1)
          create(:album_source, album: album3, source: source2)
          create(:album_source, album: album4, source: source2)

        end

        it "filters by artists, sources, and organizations" do
          expect(Album.with_artist_organization_source(artist1.id, organization1.id, source1.id)).to match_array([album1,album2,album4])
        end

        it "matches on several ids" do
          expect(Album.with_artist_organization_source(artist2.id, [organization1.id, organization2.id], source1.id)).to match_array([album3,album2,album4])
        end

        it "does not duplicate album results" do
          expect(Album.with_artist_organization_source(artist1.id, organization2.id, source1.id)).to match_array([album1,album2])
        end

        it "can match on nothing" do
          expect(Album.with_artist_organization_source(nil, organization3.id, nil)).to match_array([])
        end

        it "does not return all if one id is nil" do
          expect(Album.with_artist_organization_source(artist2.id, nil, [source1.id, source2.id])).to match_array([album2,album4,album3])
        end

        it "returns all if nil is passed into all 3 arguments" do
          expect(Album.with_artist_organization_source(nil, nil, nil)).to match_array([album1,album2,album3,album4])
        end

        it "returns an active record relation" do
          expect(Album.with_artist_organization_source(artist2.id, nil, nil).class).to_not be_a(Array)
        end
      end

    end

    describe "filters by user_settings" do
      let(:user1) {create :user}
      let(:user2) {create :user}
      let(:album1) {create :album} #ignored album from user 1
      let(:album2) {create :album} #ignored album from user 2
      let(:album3) {create :album} #limited edition of album 1
      let(:album4) {create :album} #reprint of album 2
      let(:album5) {create :album} #ignored album from user 1
      let(:album6) {create :album} #Watched album from user 1
      let(:album7) {create :album} #no relations, should always return
      before(:each) do
        create(:collection, user: user1, collected: album1, relationship: "Ignored")
        create(:collection, user: user2, collected: album2, relationship: "Ignored")
        create(:collection, user: user1, collected: album5, relationship: "Ignored")
        create(:collection, user: user1, collected: album6, relationship: "Wishlisted")
        create(:related_albums, album1: album3, album2: album1, category: "Limited Edition")
        create(:related_albums, album1: album4, album2: album2, category: "Reprint")
      end

      #1 is show LE
      #4 is show ignored
      #64 is show reprints

      it "filters out ignored albums" do
        user1.update_attribute("display_bitmask", 65)
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album3,album4,album6,album7])
      end

      it "filters out reprints" do
        user1.update_attribute("display_bitmask", 5)
        expect(Album.filter_by_user_settings(user1)).to match_array([album1,album2,album3,album5,album6,album7])
      end

      it "filters out limited editions" do
        user1.update_attribute("display_bitmask", 68)
        expect(Album.filter_by_user_settings(user1)).to match_array([album1,album2,album4,album5,album6,album7])
      end

      it "filters an album out if it matches on LE but not reprint" do
        user1.update_attribute("display_bitmask", 64)
        album8 = create(:album)
        create(:related_albums, album1: album8, album2: album2, category: "Reprint")
        create(:related_albums, album1: album4, album2: album1, category: "Limited Edition")
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album6,album7,album8])
      end

      it "filters an album out if it matches on ignored but not LE" do
        user1.update_attribute("display_bitmask", 1)
        create(:collection, user: user1, collected: album3, relationship: "Ignored")
        create(:related_albums, album1: album6, album2: album1, category: "Limited Edition")
        expect(Album.filter_by_user_settings(user1)).to match_array([album2,album6,album7])
      end

      it "returns all if nil is passed in" do
        expect(Album.filter_by_user_settings(nil)).to match_array([album1,album2,album3,album4,album5,album6,album7])
      end

      it "returns an active scope relation" do
        expect(Album.filter_by_user_settings(user1).class).to_not be_a(Array)
      end
    end
  end

end


