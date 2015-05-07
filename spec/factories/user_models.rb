# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #User Models - 
    factory :user do 
      name {Faker::Lorem.characters(10)}
      email {Faker::Internet.email}
      password "hehepassword1"
      password_confirmation "hehepassword1"
      #security "2" <- this is set on creation
      
      #We need to destroy user sessions from created users
      #for controller testing etc.
      #If we do want a user session, we'll have to call UserSession.create(user)
      after(:create) do |user|
        #Including the conditional UserSession.find.record == user ensures
        #we aren't destroying already existing user sessions
        begin
          UserSession.find.destroy if UserSession.find.record == user
        rescue Authlogic::Session::Activation::NotActivatedError
          #This rescue is for models. Since we didn't activate authlogic,
          #it can't use UserSession.find
          #This rescue does the same thing as if it met the conditional:
          #Resucing from the error means that UserSession 
          #never worked in the first palce
        end
      end
      
      factory :admin do
        after(:create) do |user|
          user.security = "1"
          user.save
        end
      end
      
      trait :with_watchlist_artist do
        after(:create) do |user|
          create(:watchlist, :with_artist, user: user)
        end        
      end          
      
      trait :with_watchlist_organization do
        after(:create) do |user|
          create(:watchlist, :with_organization, user: user)
        end        
      end     
      
      trait :with_watchlist_source do
        after(:create) do |user|
          create(:watchlist, :with_source, user: user)
        end        
      end  
      
      trait :with_multiple_watchlists do
        after(:create) do |user|
          [:with_artist, :with_organization, :with_source].each do |trait|
            create(:watchlist, trait, user: user)
          end
        end
      end
      
      trait :with_collection_album do
        after(:create) do |user|
          create(:collection, :with_album, user: user)
        end        
      end   
      
      trait :with_collection_song do
        after(:create) do |user|
          create(:collection, :with_song, user: user)
        end        
      end            

      trait :with_multiple_collections do
        after(:create) do |user|
          [:with_album, :with_song].each do |trait|
            create(:collection, trait, user: user)
          end
        end
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