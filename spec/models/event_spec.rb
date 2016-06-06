require 'rails_helper'

describe Event do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has the association module"
    include_examples "it is a translated model"
    include_examples "it has logs"
    include_examples "it has a custom json method"
    include_examples "it has references"

    include_examples "it has form_fields"
  end

  describe "Association Tests" do
    describe "Album Events" do
      include_examples "it has_many through", Album, AlbumEvent, :with_album_event
    end
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    it_behaves_like "is valid with or without an attribute", :shorthand, "name"
    it_behaves_like "is valid with or without an attribute", :start_date, Date.new(2132,1,4)
    it_behaves_like "is valid with or without an attribute", :end_date, Date.new(2032,3,12)

    it "is valid with the same start and end dates" do
      create(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end
  end

  describe "Instance Method Tests" do
    describe "name_helper" do
      it "returns the right name with name_helper" do
        expect(create(:event, name: "hi", shorthand: "this one!").name_helper("shorthand", "name")).to eq("this one!")
      end

      it "returns nil if no name_helper name matches" do
        expect(create(:event, name: "hi", shorthand: "this one!").name_helper("nope", "nada")).to eq(nil)
      end

      it "skips non-eligable names with name_helper" do
        expect(create(:event, name: "hi", shorthand: "this one!").name_helper("hi", "shorthand", "name")).to eq("this one!")
      end
    end
  end

end

describe AlbumEvent do
  include_examples "global model tests" #Global Tests

  describe "Association Tests" do
    it_behaves_like "a join table", Album, Event
  end
end


