require 'rails_helper'

describe Post do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:post)
      expect(instance).to be_valid
    end
    
  #Shared Examples
    it_behaves_like "it has images", Post, :post
    
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
    
  #Validation Tests
    it "is valid with a category and visibility" do
      expect(build(:post)).to be_valid
    end
    
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
            
    it "is invalid without a category" do
      expect(build(:post, category: "")).to_not be_valid
      expect(build(:post, category: nil)).to_not be_valid
    end
    
    it "is invalid if it's a category that is not included in categories" do
      expect(build(:post, category: "heyheyhey")).to_not be_valid
    end
        
    it "is invalid without a visibility" do
      expect(build(:post, visibility: "")).to_not be_valid
      expect(build(:post, visibility: nil)).to_not be_valid      
    end
    
    it "is valid without a title" do
      expect(build(:post, title: "")).to be_valid
      expect(build(:post, title: nil)).to be_valid     
    end
    
    it "is valid without content" do
      expect(build(:post, content: "")).to be_valid
      expect(build(:post, content: nil)).to be_valid       
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
    
  #Validation Tests
    it "is valid with a post and model" do
      expect(build(:postlist)).to be_valid
    end
    
    it "is valid with an album" do
      expect(build(:postlist, :with_album)).to be_valid
    end
    
    it "is valid with an artist" do
      expect(build(:postlist, :with_artist)).to be_valid
    end
    
    it "is valid with an organization" do
      expect(build(:postlist, :with_organization)).to be_valid
    end
    
    it "is valid with a song" do
      expect(build(:postlist, :with_song)).to be_valid
    end
    
    it "is valid with a source" do
      expect(build(:postlist, :with_source)).to be_valid
    end
        
    it "is invalid without a post" do
      expect(build(:postlist, post: nil)).to_not be_valid
    end
    
    it "is invalid without a real post" do
      expect(build(:postlist, post_id: 999999999)).to_not be_valid
    end
    
    it "is invalid without a model type" do
      expect(build(:postlist, model_type: nil)).to_not be_valid      
    end

    it "is invalid without a model_id" do
      expect(build(:postlist, model_id: nil)).to_not be_valid      
    end
    
    it "is invalid without a real model" do
      expect(build(:postlist, model_type: "Album", model_id: 999999999)).to_not be_valid      
    end
    
    it "is valid with unique post/model_type combinatioin" do
      @post = create(:post)
      expect(create(:postlist, :with_artist, post: @post)).to be_valid
      expect(build(:postlist, :with_artist, post: @post)).to be_valid    
    end
    
    it "should have a unique tag/subject combination" do
      @post = create(:post)
      @model = create(:album)
      expect(create(:postlist, post: @post, model: @model)).to be_valid
      expect(build(:postlist, post: @post, model: @model)).to_not be_valid      
    end
  
end
