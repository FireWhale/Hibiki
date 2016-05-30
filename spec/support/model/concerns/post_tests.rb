require 'rails_helper'

module PostTests
  shared_examples "it has posts" do 
    describe "Post Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      
      describe "Associations" do
        it "has many postlists" do
          expect(create(model_symbol, :with_post).postlists.first).to be_a Postlist
          expect(described_class.reflect_on_association(:postlists).macro).to eq(:has_many)
        end
        
        it "has many posts" do
          expect(create(model_symbol, :with_post).posts.first).to be_a Post
          expect(described_class.reflect_on_association(:posts).macro).to eq(:has_many)
        end
        
        it "destroys postlists when destroyed" do
          record = create(model_symbol, :with_post)
          expect{record.destroy}.to change(Postlist, :count).by(-1)
        end
        
        it "does not destroy posts when destroyed" do
          record = create(model_symbol, :with_post)
          expect{record.destroy}.to change(Post, :count).by(0)
        end
        
        it "returns a list of posts who are mentioning this #{model_symbol}" do
          #This tests the :through option
          record = create(model_symbol)
          list = create_list(:postlist, 3, model: record)
          expect(record.posts).to eq(list.map(&:post))
        end
      end
        
      describe "Callbacks" do
        it "alters the post's status with a notification that the record has been deleted" do
          record = create(model_symbol)
          post = create(:post, status: "Released")
          postlist = create(:postlist, post: post, model: record)
          expect(record.posts).to eq([post]) #For some reason, need this to make it register posts
          record.destroy
          expect(post.reload.status).to eq("Has Deleted Records")
        end
      end
      
    end
  end
end
