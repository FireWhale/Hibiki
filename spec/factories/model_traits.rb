require 'faker' 

FactoryGirl.define do
  #Polymorphics!
    trait :with_image do
      after(:create) do |record|
        create(:imagelist, model: record)
      end
    end
    
    trait :with_post do
      after(:create) do |record|
        create(:postlist, model: record)
      end
    end
    
    trait :with_tag do
      after(:create) do |record|
        create(:taglist, subject: record)
      end
    end
    
    trait :with_watcher do
      after(:create) do |record|
        create(:watchlist, watched: record)
      end    
    end
    
    trait :with_info do
      info {Faker::Lorem.paragraphs(2)}
    end
    
    trait :with_private_info do
      private_info {Faker::Lorem.paragraphs(2)}
    end
    
    trait :with_reference do
      reference {{:VGMdb => Faker::Internet.url('vgmdb.net')}}
    end
        
end