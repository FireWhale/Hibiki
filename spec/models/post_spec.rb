require 'rails_helper'

describe Post do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:post)
      expect(instance).to be_valid
    end
    
  #Shared Examples
    it_behaves_like "it has images", :post, Post
    
  #Association Test
    it "has many postlists" do
      expect(create(:post, :with_postlist_album).postlists.first).to be_a Postlist
      expect(Post.reflect_on_association(:postlists).macro).to eq(:has_many)
    end
    
    it "has many albums" do
      expect(create(:post, :with_postlist_album).albums.first).to be_a Album
      expect(Post.reflect_on_association(:albums).macro).to eq(:has_many)
    end
    
    it "has many artists" do
      expect(create(:post, :with_postlist_artist).artists.first).to be_a Artist
      expect(Post.reflect_on_association(:artists).macro).to eq(:has_many)
    end
    
    it "has many organizations" do
      expect(create(:post, :with_postlist_organization).organizations.first).to be_a Organization
      expect(Post.reflect_on_association(:organizations).macro).to eq(:has_many)
    end
    
    it "has many songs" do
      expect(create(:post, :with_postlist_song).songs.first).to be_a Song
      expect(Post.reflect_on_association(:songs).macro).to eq(:has_many)
    end
    
    it "has many sources" do
      expect(create(:post, :with_postlist_source).sources.first).to be_a Source
      expect(Post.reflect_on_association(:sources).macro).to eq(:has_many)
    end
    
    it "can belong to a user" do
      expect(create(:post, :by_user).user).to be_a User
      expect(Post.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
    
    it "can go to a recipient" do
      expect(create(:post, :to_recipient).recipient).to be_a User
      expect(Post.reflect_on_association(:recipient).macro).to eq(:belongs_to)      
    end
    
    it "destroys postlists when destroyed" do
      post = create(:post, :with_postlist_album)
      expect{post.destroy}.to change(Postlist, :count).by(-1)
    end
    
    it "does not destroy other records when destroyed" do
      post = create(:post, :with_postlist_album)
      expect{post.destroy}.to change(Album, :count).by(0)      
    end
    
    it "does not destroy users when destroyed" do
      post = create(:post, :by_user)
      expect{post.destroy}.to change(User, :count).by(0)      
    end
    
    it "does not destroy recipients when destroyed" do
      post = create(:post, :to_recipient)
      expect{post.destroy}.to change(User, :count).by(0)      
    end
    
  #Validation Tests
    include_examples "is invalid without an attribute", :post, :category
    include_examples "is invalid without an attribute", :post, :visibility
    include_examples "is invalid without an attribute", :post, :status

    include_examples "is invalid without an attribute in a category", :post, :category, Post::Categories - ["Private Message", "Blog Post"], "Post::Categories"
    include_examples "is invalid without an attribute in a category", :post, :status, Post::Status, "Post::Status"

    include_examples "is valid with or without an attribute", :post, :title, "hi"
    include_examples "is valid with or without an attribute", :post, :content, "haha this is content!"
    include_examples "is valid with or without an attribute", :post, :user_info, "User:, Recipient:"
   
    it "is valid with multiple postlists" do
       expect(build(:post, :with_multiple_postlists)).to be_valid
    end

    it "is valid without a user" do
      expect(build(:post, user_id: nil, category: "Scrape Result")).to be_valid
    end
    
    it "is invalid without a user if category is Blog Post" do
      expect(build(:post, user_id: nil, category: "Blog Post")).to_not be_valid
    end

    it "is invalid without a real user if category is Blog Post" do
      expect(build(:post, user_id: 999999999, category: "Blog Post")).to_not be_valid
    end
    
    it "is invalid without a real user and recipient if category is Private Message" do
      expect(build(:post, user_id: nil, category: "Private Message")).to_not be_valid
      expect(build(:post, user_id: 999999999, category: "Private Message")).to_not be_valid
      expect(build(:post, recipient_id: nil, category: "Blog Post")).to_not be_valid
      expect(build(:post, recipient_id: 999999999, category: "Blog Post")).to_not be_valid
    end
                
    it "is valid even with all fields duplicated" do
      @user = create(:user)
      expect(create(:post, user: @user, recipient: @user, title: "hi")).to be_valid
      expect(build(:post, user: @user, recipient: @user, title: "hi")).to be_valid
    end
    
  #Scoping Tests
  describe "scoping tests" do
    before(:each) do
      user = create(:user)
      @scrapes = create_list(:post, 4, category: "Scrape Result")
      @blogs = create_list(:post, 3, category: "Blog Post", user: user)
      @ll = create_list(:post, 2, category: "Luelinks Post")
      @records = create_list(:post, 2, category: "Records")
      @rescrapes = create_list(:post, 4, category: "Rescrape Result")
      @pms = create_list(:post, 4, category: "Private Message", user: user, recipient: user)
    end
    
    it "returns an array of scrape posts" do
      expect(Post.scrape_results).to eq(@scrapes)
    end
    
    it "returns an array of rescrape posts" do
      expect(Post.rescrape_results).to eq(@rescrapes)
    end
    
    it "returns an array of LL posts" do
      expect(Post.luelinks_posts).to eq(@ll)
    end
    
    it "returns an array of blog posts" do
      expect(Post.blog_posts).to eq(@blogs)
    end
    
    it "returns an array of private messages" do
      expect(Post.private_messages).to eq(@pms)
    end
    
    it "returns scrape and rescrape results" do
      expect(Post.scrape_and_rescrape_results).to eq(@scrapes + @rescrapes)
    end
    
  end
    it "returns a list of posts with destroyed records" do
      destroyed = create_list(:post, 2, status: "Deleted Records")
      expect(Post.destroyed_records).to eq(destroyed)
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
          expect(post.primary_records).to match_array([record])
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
      
      it "associates the user"
      
      it "associates the recipient"
      
      it "adds the user and recipient to the recipient field" #in case the user or recipient is destroyed
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
        include_examples "updates with keys and values", :post
        include_examples "can upload an image", :post
        include_examples "updates with normal attributes", :post
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
  #Gutcheck Test
    it "has a valid factory" do
      expect(create(:postlist)).to be_valid
    end
  
  #Association Tests
    it "belongs to a model" do
      expect(create(:postlist, :with_album).model).to be_a Album
      expect(Postlist.reflect_on_association(:model).macro).to eq(:belongs_to)      
    end
    
    it "belongs to a post" do
      expect(create(:postlist).post).to be_a Post
      expect(Postlist.reflect_on_association(:post).macro).to eq(:belongs_to)      
    end

    it "does not destroy the post when destroyed" do
      postlist = create(:postlist)
      expect{postlist.destroy}.to change(Post, :count).by(0)
    end
    
    it "des not destroy the model when destroyed" do
      postlist = create(:postlist, :with_album)
      expect{postlist.destroy}.to change(Album, :count).by(0)      
    end
    
  #Validation Tests
    it_behaves_like "it is a polymorphic join model", :postlist, "post", "model", "album", ["album", "artist", "organization", "source", "song"]
  
end
