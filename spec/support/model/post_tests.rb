require 'rails_helper'

module PostTests
  shared_examples "it has posts" do |model, model_class|
    #Associations 
      it "is valid with posts" do
        expect(build(model, :with_post)).to be_valid
      end 
      
      it "has many postlists" do
        expect(create(model, :with_post).postlists.first).to be_a Postlist
        expect(model_class.reflect_on_association(:postlists).macro).to eq(:has_many)
      end
      
      it "has many posts" do
        expect(create(model, :with_post).posts.first).to be_a Post
        expect(model_class.reflect_on_association(:posts).macro).to eq(:has_many)
      end
      
      it "destroys postlists when destroyed" do
        record = create(model, :with_post)
        expect{record.destroy}.to change(Postlist, :count).by(-1)
      end
      
      it "does not destroy posts when destroyed" do
        record = create(model, :with_post)
        expect{record.destroy}.to change(Post, :count).by(0)
      end

    #Validations
      it "is valid with multiple postlists and posts" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(:postlist, number, model: record)
        expect(record.postlists).to match_array(list)
        expect(record.posts.count).to eq(number)
        expect(record).to be_valid
      end
    
    it "alters the post's status with a notification that the record has been deleted"
  end
end
