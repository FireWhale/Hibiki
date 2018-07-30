require 'rails_helper'

describe ImagesController do

  #Authenticate
  before :each do
    activate_authlogic
  end

  context 'public access to images' do
    #Shows
      include_examples 'has an index page', false, :id
      include_examples "has a show page", false

    #Edits
      include_examples "has an edit page", false

    #Posts
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false

    #Strong Parameters
      include_examples "uses strong parameters"

  end

  context 'user access to images' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end

    #Shows
      include_examples 'has an index page', false, :id
      include_examples "has a show page", false

    #Edits
      include_examples "has an edit page", false

    #Posts
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false

    #Strong Parameters
      include_examples "uses strong parameters"

  end

  context 'admin access to images' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end

    #Shows
      include_examples 'has an index page', true, :id
      include_examples "has a show page", true

    #Edits
      include_examples "has an edit page", true

    #Posts
      include_examples "can post update", true, :name

    #Delete
      include_examples "can delete a record", true

    #Strong Parameters
      include_examples "uses strong parameters", valid_params: ["name", "primary_flag", "rating" ]

  end
end


