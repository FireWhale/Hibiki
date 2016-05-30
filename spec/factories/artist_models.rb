# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  factory :artist do
    internal_name {Faker::Name.name}
    status {Album::Status.sample}

    trait :with_other_attributes do
      synonyms {Faker::Lorem.sentence}
      db_status {Artist::DatabaseStatus.sample}
      activity {Artist::Activity.sample}
      category {Artist::Categories.sample}
      info {Faker::Lorem.sentence}
      private_info {Faker::Lorem.sentence}
      synopsis {Faker::Lorem.sentence}
      popularity {Faker::Number.number(2)}
      gender {Faker::Lorem.sentence}
      birth_place {Faker::Lorem.sentence}
      blood_type {Faker::Lorem.word}
      birth_date {Faker::Date.between(2.years.ago, Date.today)}
      debut_date {Faker::Date.between(2.years.ago, Date.today)}
      namehash {{:haha => "hoho"}}
    end

    trait :full_attributes do
      with_other_attributes

      birth_date_bitmask { 6 }
      debut_date_bitmask { 6 }
      
      with_name_translations
      with_info_translations
    end
    
    trait :form_input do
      with_other_attributes
      
      reference_form_attributes
      image_form_attributes
      info_form_attributes
      name_form_attributes
      
      new_related_artists {{:id => ["1", "2"], :category => ["Alias", "Subunit"]}}
      remove_related_artists ["3"]
      update_related_artists { {"4" => {:category => "Voice"}, "2" => {:category => "Member"}} } 

      new_organizations {{:id => ["2","3"], :category => ["Founder", "Former Member"]}}
      update_artist_organizations {{"5" => {:category => "Member"}, "3" => {:category => "Label"} }}
      remove_artist_organizations ["5","3"]
    end

    trait :with_self_relation do
      after(:create) do |record|
        create(:related_artists, artist1: record)
        create(:related_artists, artist2: record)
      end            
    end
    
    trait :with_primary_relations do
      after(:create) do |record|
        create(:artist_album, artist: record)
        create(:artist_organization, artist: record)
        create(:artist_song, artist: record)
      end            
    end
    
    trait :with_albums do
      after(:create) {|artist| 5.times { create(:artist_album,artist: artist, album: create(:album, :full_attributes))}}
    end
    
    trait :invalid do
      internal_name ""
    end
  end
end