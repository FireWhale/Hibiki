# encoding: utf-8
require 'faker'

FactoryGirl.define do
  factory :album do
    internal_name {Faker::Lorem.sentence}
    status {Album::Status.sample}
    catalog_number {Faker::Lorem.word}

    trait :with_other_attributes do
      synonyms {Faker::Lorem.sentence}
      info {Faker::Lorem.sentence}
      private_info {Faker::Lorem.sentence}
      classification { Faker::Lorem.sentence} #To be removed at a later date
      release_date {Faker::Date.between(2.years.ago, Date.today)}
      popularity {Faker::Number.number(2)}
      namehash {{:haha => "hoho"}}
    end

    trait :full_attributes do
      with_other_attributes

      release_date_bitmask { 6 }

      with_name_translations
      with_info_translations
    end

    trait :form_input do
      with_other_attributes

      reference_form_attributes
      image_form_attributes
      info_form_attributes
      name_form_attributes

      new_events {{:id => ["5", "3"]}}
      remove_album_events {["3","6"]}

      new_related_albums {{:id => ["1", "2"], :category => ["Alias", "Subunit"]}}
      remove_related_albums ["3"]
      update_related_albums { {"4" => {:category => "Voice"}, "2" => {:category => "Member"}} }

      new_artists {{:id => ["5", "4"], :category =>  (Artist::Credits.sample(2) + ["New Artist"] + Artist::Credits.sample(2))}}
      update_artist_albums {{"5" => {:category => Artist::Credits.sample(4)}, "3" => {:category =>[]}}} #empty array will trigger destroy

      new_sources {{:id => ["1","2"]}}
      remove_album_sources ["5"]

      new_organizations {{:id => ["2","3"], :category => ["Publisher", "Distributor"]}}
      update_album_organizations {{"10" => {:category => "Publisher"}, "2" => {:category => "Publisher"} }}
      remove_album_organizations ["5","3"]

      new_songs {{:track_number => ["1.01", "1.02"], :internal_name => ["name", "namae"]}}

    end

    trait :with_self_relation do
      after(:create) do |record|
        create(:related_albums, album1: record)
        create(:related_albums, album2: record)
      end
    end

    trait :with_primary_relations do
      after(:create) do |record|
        create(:album_source, album: record)
        create(:artist_album, album: record)
        create(:album_organization, album: record)
      end
    end

    trait :with_album_event do
      after(:create) do |record|
        create(:album_event, album: record)
      end
    end

    trait :with_song do
      after(:create) do |record|
        create(:song, album: record)
      end
    end

    trait :with_songs do
      after(:create) do |record|
        create_list(:song, 6, album: record)
      end
    end

    trait :invalid do
      internal_name ""
    end
  end
end