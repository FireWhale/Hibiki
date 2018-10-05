require 'rails_helper'
require 'cancan/matchers'

describe PrimaryRecordCounter do

  describe 'Search Counting' do

    it 'counts the number of records in a model with a search term' #Stub this. 

  end

  describe 'Index Counting' do
    it 'counts all records of a model' do
      create_list(:albums, 8)
      expect(PrimaryRecordCounter.perform('index',model: 'album')).to eq(8)
    end
  end

  describe 'Collection Counting' do
    let(:user) {create(:user)}

    it 'counts albums and songs in collection' do
      create_list(:collection, 2, :with_album, user: user, relationship: 'Collected')
      create_list(:collection, 2, :with_song, user: user, relationship: 'Collected')
      expect(PrimaryRecordCounter.perform('collection', col_user: user, col_category: 'Collected')).to eq (4)
    end

    it 'counts albums and songs of a specific category in a collection' do
      create_list(:collection, 3, :with_album, user: user, relationship: 'Ignored')
      create_list(:collection, 2, :with_album, user: user, relationship: 'Collected')
      expect(PrimaryRecordCounter.perform('collection', col_user: user, col_category: 'Collected')).to eq (2)
    end

    it 'does not need to have songs or albums to count' do
      create_list(:collection, 2, :with_album, user: user, relationship: 'Collected')
      expect(PrimaryRecordCounter.perform('collection', col_user: user, col_category: 'Collected')).to eq (2)

    end
  end

end