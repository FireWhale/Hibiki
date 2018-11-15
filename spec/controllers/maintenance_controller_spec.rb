require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe MaintenanceController do
  include_examples "global controller tests" #Global Tests

  shared_examples 'can get index' do |accessible|
    describe "#GET index" do
      it "renders the :index template" do
        get :index
        valid_permissions(:index, accessible)
      end
    end
  end

  shared_examples 'can scrape' do |accessible|
    describe "#GET new_scrape" do
      it "renders the :new_scrape template" do
        get :new_scrape
        valid_permissions(:new_scrape, accessible)
      end
    end

    describe "#GET scrape_results" do
      it "renders the scrape_results template" do
        get :scrape_results
        valid_permissions(:scrape_results, accessible)
      end

      if accessible == true
        it "accepts a log id" do
          logs = create_list(:log, 5, category: "Scrape")
          get :scrape_results, params: {log_id: logs.first.id}
          expect(assigns(:log)).to eq(logs.first)
        end

        it "accepts a log category" do
          log = create(:log, category: "Rescrape")
          logs = create_list(:log, 5, category: "Scrape")
          get :scrape_results, params: {log_category: log.category}
          expect(assigns(:log)).to eq(log)

        end

        it "uses the last log if no log is provided" do
          logs = create_list(:log, 5, category: "Scrape")
          get :scrape_results
          expect(assigns(:log)).to eq(logs.last)
        end
      end
    end

    describe "#GET generate_urls" do
      it "renders the generate_urls template" do
        post = create(:post, content: "hi: 424")
        allow(Post).to receive(:find).and_return(post)
        get :generate_urls
        valid_permissions(:generate_urls, accessible)
      end
    end

    describe "#POST scrape" do
      if accessible == true

        context "with a valid url" do
          it "redirects to scrape results" do
            post :scrape, params: {vgmdb_artists: ["wa"]}
            expect(response).to redirect_to %r(maintenance/scrape_results) #good enough
          end

          it "sends off a sidekiq request" do
            expect{post :scrape, params: {vgmdb_artists: ["wa"]}}.to change(ScrapeWorker.jobs, :size).by(1)
          end


          it "sends off a sidekiq request with json" do
            expect{post :scrape, params: {vgmdb_artists: ["wa"]}, format: :json}.to change(ScrapeWorker.jobs, :size).by(1)
          end

          it "responds with json" do
            post :scrape, params: {vgmdb_artists: ["wa"]}, format: :json
            expect(response.status).to eq(204) #204 No Content -> ajax success event
          end
        end

        context "without valid urls" do
          it "redirects to new_scrape again" do
            post :scrape
            expect(response).to redirect_to(:action => :new_scrape)
          end

           it "does not send off a sidekiq request" do
            expect{post :scrape, params: {vgmdb_artisats: ["wa"]}}.to change(ScrapeWorker.jobs, :size).by(0)
          end

          it "responds with json" do
            post :scrape, format: :json
            expect(response.status).to eq(422) #aka Unprocessable entity
          end
        end

      else
        it "should render access_denied" do
          post :scrape
          expect(response).to render_template("pages/access_denied")
        end

        it "does not create a post" do
          expect{post :scrape, params: {vgmdb_artists: ["wa"]}}.to change(Post,:count).by(0)
        end

        it "does not send off a sidekiq request" do
          expect{post :scrape, params: {vgmdb_artists: ["wa"]}, format: :json}.to change(ScrapeWorker.jobs, :size).by(0)
        end
      end
    end

    describe "#POST update_scrape_number" do
      if accessible == true

        it "responds to js" do
          posta = create(:post, content: "hi: 424")
          allow(Post).to receive(:find).and_return(posta)
          post :update_scrape_number, xhr: true, params: {vgmdb_number: {id: 500}}
          expect(response).to render_template(:update_scrape_number)
        end

      else
        it "should render access_denied" do
          post :update_scrape_number
          expect(response).to render_template("pages/access_denied")
        end
      end
    end

  end

  shared_examples 'can access workqueues' do |accessible|
    [Artist, Source, Organization].each do |model_class|
      model_symbol = model_class.model_name.param_key.to_sym

      describe "#GET #{model_symbol}_workqueue" do
        if accessible == true
          it "populates a list of #{model_symbol}" do
            list = create_list(model_symbol, 5, status: "Unreleased")
            get "#{model_symbol}_workqueue".to_sym
            expect(assigns("#{model_symbol}s")).to match_array(list)
          end

          it "returns unreleased #{model_symbol}s" do
            list = create_list(model_symbol, 20)
            filtered_list = list.reject { |record| record.status != "Unreleased"}
            get "#{model_symbol}_workqueue".to_sym
            expect(assigns("#{model_symbol}s")).to match_array(filtered_list)
          end

          it "calls pagination" do
            list = create_list(model_symbol, 5, status: "Unreleased")
            expect(model_class).to receive(:page)
            get "#{model_symbol}_workqueue".to_sym
          end

          it "sorts by reverse id" do
            list = create_list(model_symbol, 5, status: "Unreleased")
            get "#{model_symbol}_workqueue".to_sym
            expect(assigns("#{model_symbol}s")).to eq(list.sort_by!(&:id).reverse!)
          end

          it "returns a json object" do
            list = create_list(model_symbol, 5, status: "Unreleased")
            get "#{model_symbol}_workqueue".to_sym, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response.body).to eq(list.sort_by!(&:id).reverse!.to_json)
          end
        end

        it "renders the :#{model_symbol}_workqueue template" do
          get "#{model_symbol}_workqueue".to_sym
          valid_permissions("#{model_symbol}_workqueue".to_sym, accessible)
        end

      end
    end

    describe '#GET update_available_albums' do
      it 'renders the update_available_albums template' do
        get :update_available_albums
        valid_permissions(:update_available_albums, accessible)
      end

      if accessible == true
        it "does other stuff" #Not important to write tests for atm
      end
    end

    describe '#GET le_workqueue' do
      it 'renders the le_workqueue template' do
        get :le_workqueue
        valid_permissions(:le_workqueue, accessible)
      end

      if accessible == true
        it "does other stuff"  #Not important to write tests for atm

      end

    end

    describe '#GET released_review' do
      it 'renders the released_review template' do
        get :released_review
        valid_permissions(:released_review, accessible)
      end

      if accessible == true
        it "does other stuff"  #Not important to write tests for atm

      end

    end

  end

  #Authenticate
  before :each do
    activate_authlogic
  end

  context 'public access to maintenance' do

    include_examples "can get index", false

    #Scraping
    include_examples "can scrape", false

    #Workqueues
    include_examples 'can access workqueues', false

  end

  context 'user access to maintenance' do
    before :each do
      @user = create(:user, :user_role)
      UserSession.create(@user)
    end

    include_examples "can get index", false

    #Scraping
    include_examples "can scrape", false

    #Workqueues
    include_examples 'can access workqueues', false

  end

  context 'admin access to maintenance' do
    before :each do
      @user = create(:user, :admin_role)
      UserSession.create(@user)
    end

    include_examples "can get index", true

    #Scraping
    include_examples "can scrape", true

    #Workqueues
    include_examples 'can access workqueues', true

  end
end


