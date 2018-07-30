require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe AlbumsController do
  shared_examples "has an edit_tracklist page" do |accessible|
    describe 'GET #edit_tracklist' do

      it "populates an album record" do
        album = create(:album)
        get :edit_tracklist, params: {id: album}
        expect(assigns(:album)).to eq album
      end

      it "responds to json" do
        album = create(:album)
        get :edit_tracklist, format: :json, params: {id: album}
        if accessible == true
          expect(response.body).to eq(album.to_json)
        else
          expect(response.status).to eq(403)
        end
      end

      it "renders the :edit_tracklist template" do
        album = create(:album)
        get :edit_tracklist, params: {id: album}
        valid_permissions(:edit_tracklist, accessible)
      end
    end
  end

  shared_examples "can post update_tracklist" do |accessible|
    describe 'POST #update_tracklist' do
      if accessible == true
        it "locates the album" do
          album = create(:album, :with_songs)
          put :update_tracklist, params: {id: album}
          expect(assigns(:album)).to eq album
        end

        it "updates each song in the album" do
          album = create(:album, :with_songs)
          new_info = attributes_for(:song, internal_name: "hohoho")
          put :update_tracklist, params: {id: album, song: {album.songs.first.id.to_s => new_info}}
          expect(album.songs.first.reload.internal_name).to eq("hohoho")
        end

        it "redirects to the album" do
          album = create(:album, :with_songs)
          put :update_tracklist,params: {id: album}
          expect(response).to redirect_to album_path(assigns[:album])
        end

        it "responds to json" do
          album = create(:album, :with_songs)
          put :update_tracklist,params: {id: album}, format: :json
          expect(response.status).to eq(204) #204 No Content -> ajax success event
        end
      else
        it "does not update any songs" do
          album = create(:album, :with_songs)
          new_info = attributes_for(:song, name: "hohoho")
          song_info = {album.songs.first.id => new_info}
          put :update_tracklist,params: {id: album, song: song_info}
          expect(album.songs.first.reload.name).to_not eq("hohoho")
        end

        it "redirects to the access denied" do
          album = create(:album, :with_songs)
          put :update_tracklist,params: {id: album}
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
  end

  shared_examples "can post rescrape" do |accessible|
    describe 'POST #rescrape' do
      before(:each) do
        Sidekiq::Worker.clear_all
      end

      if accessible == true
        it "locates the album" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape,params: {id: album}
          expect(assigns(:album)).to eq(album)
        end

        it "redirects to the album" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape,params: {id: album}
          expect(response).to redirect_to album_path(assigns[:album])
        end

        it "responds to json" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape,params: {id: album}, format: :json
          expect(response.status).to eq(204) #204 No Content -> ajax success event
        end

        it "responds to a get request" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          get :rescrape,params: {id: album}
          expect(response).to redirect_to album_path(assigns[:album])
        end

        context 'with vgmdb reference' do
          it "sends off a sidekiq request" do
            album = create(:album)
            create(:reference, model: album, site_name: "VGMdb")
            post = create(:post, category: "Rescrape Result", content: "hi")
            expect{put :rescrape,params: {id: album}}.to change(ScrapeWorker.jobs, :size).by(1)
          end

          it "sends a sidekiq request with get" do
            album = create(:album)
            create(:reference, model: album, site_name: "VGMdb")
            post = create(:post, category: "Rescrape Result", content: "hi")
            expect{get :rescrape,params: {id: album}}.to change(ScrapeWorker.jobs, :size).by(1)
          end
        end

        context 'without vgmdb reference' do
          it "does not send off a sidekiq request" do
            album = create(:album)
            create(:reference, model: album, site_name: "Twitter")
            post = create(:post, category: "Rescrape Result", content: "hi")
            expect{get :rescrape,params: {id: album}}.to change(ScrapeWorker.jobs, :size).by(0)
          end
        end

      else
        it "does not send off a sidekiq requset" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          expect{put :rescrape,params: {id: album}}.to change(ScrapeWorker.jobs, :size).by(0)
        end

        it "redirects to the access denied" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape,params: {id: album}
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
  end

  #Authenticate
  before :each do
    activate_authlogic
  end

  context 'public access to albums' do
    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page", true, :album_art

    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false
      include_examples "has an edit_tracklist page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false

    #Delete
      include_examples "can delete a record", false

    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [{"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]

  end

  context 'user access to albums' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end

    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page", true, :album_art

    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false
      include_examples "has an edit_tracklist page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false

    #Delete
      include_examples "can delete a record", false

    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [{"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]

  end

  context 'admin access to albums' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end

    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page",true, :album_art

    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true
      include_examples "has an edit_tracklist page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :internal_name
      include_examples "can post update_tracklist", true
      include_examples "can post rescrape", true

    #Delete
      include_examples "can delete a record", true

    #Strong Parameters
    include_examples "uses strong parameters", valid_params: ["internal_name", "synonyms", "catalog_number", "release_date", "status", "classification", "info", "private_info",
                                                              ["new_images"], ["remove_album_sources"], ["remove_album_organizations"], ["remove_related_albums"], ["remove_album_events"], {"namehash" => "string"},
                                                              {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
                                                              {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
                                                              {"new_related_albums" => {"new" => ["id", "category"]}}, {"update_related_albums" => {"update" => ["category"]}},
                                                              {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_albums" => {"update" => [["category"]]}},
                                                              {"new_organizations" => {"new" => ["id", "category"]}}, {"update_album_organizations" => {"update" => ["category"]}},
                                                              {"new_sources" => {"new" => ["id"]}}, {"new_events" => {"new" => ["id"]}},
                                                              {"new_songs" => {"new" => ["track_number", "internal_name"]}},
                                                              {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]

      include_examples "uses strong parameters", valid_params: [{"song" => {"update" => ["internal_name", "disc_number", "track_number", "length", {"namehash" => "string"}, ["remove_song_sources"], ["remove_related_songs"],
                                                                  {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
                                                                  {"lyrics_langs" => "string"},["new_lyrics_langs"], ["new_lyrics_lang_categories"],
                                                                  {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_songs" => {"update" => [["category"]]}},
                                                                  {"new_sources" => {"new" => ["id", "classification", "op_ed_number", "ep_numbers"]}}, {"update_song_sources" => {"update" => ["classification", "op_ed_number", "ep_numbers"]}},
                                                                  {"new_related_songs" => {"new" => ["id", "category"]}}, {"update_related_songs" => {"update" => ["category"]}}]}}],
                                                      filter_method: "tracklist_filter", base_key: "none"


  end

end


