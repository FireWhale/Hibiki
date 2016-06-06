require 'rails_helper'

module TagTests
  shared_examples "it has tags" do
    describe "Tag Tests" do
      model_symbol = described_class.model_name.param_key.to_sym

      describe "Associations" do
        it "has many taglists" do
          expect(create(model_symbol, :with_tag).taglists.first).to be_a Taglist
          expect(described_class.reflect_on_association(:taglists).macro).to eq(:has_many)
        end

        it "has many tags" do
          expect(create(model_symbol, :with_tag).tags.first).to be_a Tag
          expect(described_class.reflect_on_association(:tags).macro).to eq(:has_many)
        end

        it "destroys taglists when destroyed" do
          record = create(model_symbol, :with_tag)
          expect{record.destroy}.to change(Taglist, :count).by(-1)
        end

        it "does not destroy tags when destroyed" do
          record = create(model_symbol, :with_tag)
          expect{record.destroy}.to change(Tag, :count).by(0)
        end

        it "returns a list of tags attached to a #{model_symbol}" do
          #This tests the through association
          record = create(model_symbol)
          list = create_list(:taglist, 3, subject: record)
          expect(record.tags).to match_array(list.map(&:tag))
        end
      end

      describe "Callbacks/Hooks" do
        describe "After Save: manage_tags" do
          it "creates a new taglist" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            record.new_tags = {:id => [tag.id]}
            expect{record.save}.to change(Taglist, :count).by(1)
          end

          it "doesn't add a tag that isn't allowed on the tag" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(["Album", "Organization"] - [described_class.name]))
            record.new_tags = {:id => [tag.id]}
            expect{record.save}.to change(Taglist, :count).by(0)
          end

          it "doesn't create a taglist if the tag doesn't exist" do
            record = create(model_symbol)
            record.new_tags = {:id => [5]}
            expect{record.save}.to change(Taglist, :count).by(0)
          end

          it "creates multiple taglists" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            tag2 = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            record.new_tags = {:id => [tag.id, tag2.id]}
            expect{record.save}.to change(Taglist, :count).by(2)
          end

          it "can add by name" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            record.new_tags_by_name = {:internal_name => [tag.internal_name]}
            expect{record.save}.to change(Taglist, :count).by(1)
            expect(record.tags.first).to eq(tag)
          end

          it "creates a tag if added by name" do
            record = create(model_symbol)
            record.new_tags_by_name = {:internal_name => ["hi"]}
            expect{record.save}.to change(Tag, :count).by(1)
          end

          it "creates a tag with the appropriate bitmask" do
            record = create(model_symbol)
            record.new_tags_by_name = {:internal_name => ["hi"]}
            record.save
            expect(Tag.last.model_bitmask).to eq(Tag.get_bitmask(described_class.name))
          end

          it "destroys a taglist" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            taglist = create(:taglist, tag: tag, subject: record)
            record.remove_taglists = [taglist.id]
            expect{record.save}.to change(Taglist, :count).by(-1)
          end

          it "doesn't destroy a tag when destroying taglists" do
            record = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            taglist = create(:taglist, tag: tag, subject: record)
            record.remove_taglists = [taglist.id]
            expect{record.save}.to change(Tag, :count).by(0)
          end

          it "doesn't destroy taglists that aren't on the record" do
            record = create(model_symbol)
            record2 = create(model_symbol)
            tag = create(:tag, model_bitmask: Tag.get_bitmask(described_class.name))
            taglist = create(:taglist, tag: tag, subject: record2)
            record.remove_taglists = [taglist.id]
            expect{record.save}.to change(Taglist, :count).by(0)
          end
        end
      end

      describe "Scopes" do
        let(:tag1) {create(:tag, model_bitmask: 63)}
        let(:tag2) {create(:tag, model_bitmask: 63)}
        let(:tag3) {create(:tag, model_bitmask: 63)}
        let(:tag4) {create(:tag, model_bitmask: 63)}
        let(:record1) {create(model_symbol)} #tags 1
        let(:record2) {create(model_symbol)} #tags 1 and 2
        let(:record3) {create(model_symbol)} #tags 2 and 3
        let(:record4) {create(model_symbol)} #no tags
        before(:each) do
          create(:taglist, subject: record1, tag: tag1)
          create(:taglist, subject: record2, tag: tag1)
          create(:taglist, subject: record2, tag: tag2)
          create(:taglist, subject: record3, tag: tag2)
          create(:taglist, subject: record3, tag: tag3)
        end

        it "filters by tag" do
          expect(described_class.with_tag(tag1.id)).to match_array([record1, record2])
        end

        it "filters by tag 2" do
          expect(described_class.with_tag(tag3.id)).to match_array([record3])
        end

        it "accepts multiple tags" do
          expect(described_class.with_tag([tag2.id, tag3])).to match_array([record2, record3])
        end

        it "returns nothing if the tag is not used" do
          expect(described_class.with_tag(tag4.id)).to eq([])
        end

        it "returns all records if nil is passed in" do
          expect(described_class.with_tag(nil)).to match_array([record1, record2, record3, record4])
        end

        it "returns no records if empty is passed into tag_ids" do
          expect(described_class.with_tag([])).to eq([])
        end

        it "should be an active record relation" do
          expect(described_class.with_tag(tag1.id).class).to_not be_a(Array)
        end
      end

    end
  end
end
