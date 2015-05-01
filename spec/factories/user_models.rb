# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #User Models - 
    factory :user do 
      name {Faker::Lorem.characters(10)}
      email {Faker::Internet.email}
      password "hehepassword1"
      password_confirmation "hehepassword1"
      security "2"
      
      factory :admin do
        security "1"
      end
    end
    
    factory :collection do 
      relationship {Collection::Relationship.sample}
      association :collected, factory: :album
      association :user
      
      trait :with_album do
        association :collected, factory: :album
      end
      
      trait :with_song do
        association :collected, factory: :song
      end
    end
            
    factory :watchlist do
      association :user
      association :watched, factory: :artist

      trait :with_artist do
        association :watched, factory: :artist
      end
      
      trait :with_organization do
        association :watched, factory: :organization        
      end
      
      trait :with_source do
        association :watched, factory: :source        
      end
      
    end
    
end