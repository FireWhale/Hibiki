require 'rails_helper'

describe TagsController do

  shared_examples "can add and remove tags" do |valid|
    describe 'POST #add_tag' do
      if valid == true
        
      elsif valid == false
        
      else
        Raise Exception
      end
    end
    
    describe 'POST #remove_tag' do
      if valid == true
        
      elsif valid == false
        it "removes a tag" do
          expect{put :remove_tag, id: @record}.to change(Taglist, :count).by(-1)
        end
        
        it "redirects to the record"
        
      end
    end
    
  end  

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to tags' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "tag", true
      include_examples "has a show page", "tag", true
      
    #Edits
      include_examples "has a new page", "tag", false
      include_examples "has an edit page", "tag", false

    #Posts
      include_examples "can post create", "tag", false
      include_examples "can post update", "tag", false, :name
      include_examples "can add and remove tags", false

    #Delete
      include_examples "can delete a record", "tag", false
      
  end
  
  context 'user access to tags' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "tag", true
      include_examples "has a show page", "tag", true
      
    #Edits
      include_examples "has a new page", "tag", false
      include_examples "has an edit page", "tag", false

    #Posts
      include_examples "can post create", "tag", false
      include_examples "can post update", "tag", false, :name
      include_examples "can add and remove tags", false

    #Delete
      include_examples "can delete a record", "tag", false

  end

  context 'admin access to tags' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "tag", true
      include_examples "has a show page", "tag", true
      
    #Edits
      include_examples "has a new page", "tag", true
      include_examples "has an edit page", "tag", true

    #Posts
      include_examples "can post create", "tag", true
      include_examples "can post update", "tag", true, :name
      include_examples "can add and remove tags", true

    #Delete
      include_examples "can delete a record", "tag", true
  end
   
end


