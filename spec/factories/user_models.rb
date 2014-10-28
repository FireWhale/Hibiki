# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #User Models - 
    factory :user do 
      name {Faker::Lorem.characters(10)}
      email {Faker::Internet.email}
      password "hehepassword"
      password_confirmation "hehepassword"
      security "User"
      
      factory :admin do
        security "Admin"
      end
    end
    
    factory :collection do 
      relationship {Collection::Relationship.sample}
      association :album
      association :user
    end
    
    factory :issue_user do
      comment {Faker::Lorem.paragraph}
      vote {Faker::Number.digit}
      association :issue
      association :user
    end
    
    factory :rating do
      rating {[1.100].sample}
      association :song
      association :user
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
      
      trait :with_song do
        association :watched, factory: :song
      end
    end
    
end