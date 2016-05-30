require 'rails_helper'

describe Post do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has tags"
    include_examples "it has images"
    include_examples "it has a custom json method"
    include_examples "it has custom pagination"

    it_behaves_like "it has form_fields"
  end

  describe "Callbacks/Hooks" do
    describe "parse_content callback" do
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

      it "associates an image found on another model" do
        album = create(:album, :with_image)
        image = album.images.first
        post = build(:post, content: "hahaha\r <record=\"Image,#{image.id}\">")
        expect{post.save}.to change(Imagelist, :count).by(1)
      end
    end
  end

  describe "Association Tests" do
    it_behaves_like "it is a polymorphically-linked class", Postlist, [Album, Artist, Organization, Source, Song], "model"
  end

  describe "Validation Tests" do
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
  end

  describe "Scoping" do
    it_behaves_like "filters by category", Post::Categories
    it_behaves_like "filters by status", Post::Status
    it_behaves_like "filters by security"
  end

  describe "Instance Methods" do
    describe "records" do
      it "returns a full list of records back (with records)" do
        post = create(:post)
        album = create(:album)
        image = create(:image)
        artist = create(:artist)
        create(:postlist, model: album, post: post)
        create(:postlist, model: artist, post: post)
        create(:imagelist, model: post, image: image)
        expect(post.records).to match_array([album,image,artist])
      end
    end

    describe "models" do
      it "returns a list of postlist records" do
        post = create(:post)
        album = create(:album)
        image = create(:image)
        artist = create(:artist)
        create(:postlist, model: album, post: post)
        create(:postlist, model: artist, post: post)
        create(:imagelist, model: post, image: image)
        expect(post.models).to match_array([album,artist])
      end

    end
  end

end

describe Postlist do
  include_examples "global model tests" #Global Tests

  it_behaves_like "it is a polymorphic join model", Post, [Album, Artist, Organization, Source, Song], "model"

end
