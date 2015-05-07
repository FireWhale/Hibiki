require 'rails_helper'

describe Post do
  include_examples "global model tests" #Global Tests
    
  describe "Module Tests" do
    it_behaves_like "it has images"
    it_behaves_like "it has form_fields"
    it_behaves_like "it has a custom json method"
  end
    
  #Association Test
    it_behaves_like "it is a polymorphically-linked class", Postlist, [Album, Artist, Organization, Source, Song], "model"
  
    it "returns a full list of records back (with records)"
    
    it "returns records back as an activerecord association"    
    
  #Validation Tests
    include_examples "is invalid without an attribute", :category
    include_examples "is invalid without an attribute", :visibility
    include_examples "is invalid without an attribute", :status

    include_examples "is invalid without an attribute in a category", :category, Post::Categories - ["Private Message", "Blog Post"], "Post::Categories"
    include_examples "is invalid without an attribute in a category", :status, Post::Status, "Post::Status"
    include_examples "is invalid without an attribute in a category", :visibility, Ability::Abilities, "Ability::Abilities"

    include_examples "is valid with or without an attribute", :title, "hi"
    include_examples "is valid with or without an attribute", :content, "haha this is content!"
   
    it "is valid with multiple postlists" do
       expect(build(:post, :with_multiple_postlists)).to be_valid
    end
    
  #Scoping Tests
  describe "Scoping" do    
    it_behaves_like "filters by category", Post::Categories
    it_behaves_like "filters by status", Post::Status
    it_behaves_like "filters by tag"
    it_behaves_like "filters by security"
  end

  #Callbacks
    context "before_save callback" do
      [:album, :artist, :source, :organization, :song].each do |model|
        it "parses the content and creates a postlist" do
          record = create(model)
          post = build(:post, content: "This is a <record=\"#{record.class},#{record.id}\">" )
          expect{post.save}.to change(Postlist, :count).by(1)
        end
        
        it "it adds a #{model} from content" do
          record = create(model)
          post = create(:post, content: "This is a <record=\"#{record.class},#{record.id}\">" )
          expect(post.models).to match_array([record])
        end
        
        it "does not add an improperly formatted record from content" do
          record = create(model)
          post = build(:post, content: "This is not a <record = \"#{record.class},#{record.id}\">")
          expect{post.save}.to change(Postlist, :count).by(0)
        end
      end
      
      it "adds multiple records" do
        album = create(:album)
        song = create(:song)
        post = build(:post, content: "hahaha\r <record=\"Album,#{album.id}\"> and \r <record=\"Song,#{song.id}\"> this is more content")
        expect{post.save}.to change(Postlist, :count).by(2)
      end
      
      it "parses content and adds an image" do
        image = create(:image)
        post = build(:post, content: "hahaha\r <record=\"Image,#{image.id}\">")
        expect{post.save}.to change(Imagelist, :count).by(1)
      end
      
      it "uploads an image"
       
      it "associates an image found on another model"
            
    end
  
  
  #Instance Method Tests
  
    describe "using upload_image_to_ll" do
      it "it connects the image as an association"
      
      it "returns a LL image link"
      
      it "does not upload the same image twice"
    end
    
    describe "using add_album_info to ll" do
      it "connects the album as an association"
            
      it "returns a message with record information"
    end
    
    #Full Update
      context "has a full update method" do
        include_examples "updates with keys and values"
        include_examples "can upload an image"
        include_examples "updates with normal attributes"
      end      
      
  #Class Method Tests
  
    #For LL Posts
    describe "using cuts_messages_for_ll" do
      it "passes back an array of messages"
      
      it "cuts any messages longer than 9000 characters into multiple messages"       
            
      it "returns the same array if all messages pass"
      
      it "puts a single messages into an array if only one message (<9000 characters) is given"
    end

end

describe Postlist do
  include_examples "global model tests" #Global Tests
      
  it_behaves_like "it is a polymorphic join model", Post, [Album, Artist, Organization, Source, Song], "model"
  
end
