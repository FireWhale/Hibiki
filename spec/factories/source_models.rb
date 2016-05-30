# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  factory :source do 
    #Required Attributes
    internal_name {Faker::Lorem.sentence}
    status {Album::Status.sample}

    trait :with_other_attributes do
      synonyms {Faker::Lorem.sentence}
      db_status {Artist::DatabaseStatus.sample}
      activity {Source::Activity.sample}
      category {Source::Categories.sample}
      info {Faker::Lorem.sentence}
      private_info {Faker::Lorem.sentence}
      plot_summary {Faker::Lorem.sentence}
      synopsis {Faker::Lorem.sentence}
      popularity {Faker::Number.number(2)}
      release_date {Faker::Date.between(2.years.ago, Date.today)}
      end_date {Faker::Date.between(2.years.ago, Date.today)}
      namehash {{:haha => "hoho"}}
      
    end
    
    trait :full_attributes do
      with_other_attributes
      
      release_date_bitmask { 6 }
      end_date_bitmask { 4 }
      
      with_name_translations
      with_info_translations
    end
    
    trait :form_input do
      with_other_attributes
      
      reference_form_attributes
      image_form_attributes
      info_form_attributes
      name_form_attributes
      
      new_related_sources {{:id => ["1", "2"], :category => ["Prequel", "Adaption"]}}
      remove_related_sources ["3"]
      update_related_sources { {"4" => {:category => "Parent Story"}, "2" => {:category => "Fan Disc"}} } 
      
      new_organizations {{:id => ["2","3"], :category => ["Publisher", "Distributor"]}}
      update_source_organizations {{"5" => {:category => "Publisher"}, "3" => {:category => "Distributor"} }}
      remove_source_organizations ["5","3"]
    end
    
    trait :with_self_relation do
      after(:create) do |record|
        create(:related_sources, source1: record)
        create(:related_sources, source2: record)
      end            
    end
    
    trait :with_primary_relations do
      after(:create) do |record|
        create(:album_source, source: record)
        create(:source_organization, source: record)
        create(:song_source, source: record)
      end            
    end
    
    trait :with_source_season do
      after(:create) do |record|
        create(:source_season, source: record)
      end
    end

    trait :with_albums do
      after(:create) {|source| 5.times { create(:album_source, source: source, album: create(:album, :full_attributes))}}
    end          

    trait :invalid do
      internal_name ""
    end
  end
end