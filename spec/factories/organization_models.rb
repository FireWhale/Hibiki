# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  factory :organization do
    #Required Attributes
    internal_name {Faker::Lorem.sentence}
    status {Album::Status.sample}

    trait :with_other_attributes do
      synonyms {Faker::Lorem.sentence}
      db_status {Artist::DatabaseStatus.sample}
      activity {Organization::Activity.sample}
      category {Organization::Categories.sample}
      established {Faker::Date.between(2.years.ago, Date.today)}
      info {Faker::Lorem.sentence}
      private_info {Faker::Lorem.sentence}
      popularity {Faker::Number.number(2)}
      synopsis {Faker::Lorem.sentence}
      namehash {{:haha => "hoho"}}
    end

    trait :full_attributes do
      with_other_attributes
      
      established_bitmask { 6 }
      
      with_name_translations
      with_info_translations
    end
    
    trait :form_input do
      with_other_attributes
      
      reference_form_attributes
      image_form_attributes
      info_form_attributes
      name_form_attributes
      
      new_related_organizations {{:id => ["1", "2"], :category => ["Prequel", "Adaption"]}}
      remove_related_organizations ["3"]
      update_related_organizations { {"4" => {:category => "Parent Story"}, "2" => {:category => "Fan Disc"}} } 

      new_artists {{:id => ["2","3"], :category => ["Founder", "Former Member"]}}
      update_artist_organizations {{"5" => {:category => "Member"}, "3" => {:category => "Label"} }}
      remove_artist_organizations ["5","3"]
    end

    trait :with_self_relation do
      after(:create) do |record|
        create(:related_organizations, organization1: record)
        create(:related_organizations, organization2: record)
      end            
    end
    
    trait :with_primary_relations do
      after(:create) do |record|
        create(:album_organization, organization: record)
        create(:artist_organization, organization: record)
        create(:source_organization, organization: record)
      end            
    end
    
    trait :with_albums do
      after(:create) {|organization| 5.times { create(:album_organization, organization: organization, album: create(:album, :full_attributes))}}
    end
        
    
    trait :invalid do
      internal_name ""
    end
  end
    
  
end