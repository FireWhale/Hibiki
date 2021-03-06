# encoding: utf-8
require 'faker'

FactoryBot.define do
  #User Models -
    factory :user do
      name {Faker::Lorem.characters(10)}
      email {Faker::Internet.email}
      password "hehepassword1"
      password_confirmation "hehepassword1"

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

      trait :full_attributes do
        profile {Faker::Lorem.sentence}
        birth_date {Faker::Date.between(2.years.ago, Date.today)}
        birth_date_bitmask { 6 }
        sex {Faker::Lorem.word}
        location {Faker::Lorem.word}
      end

      trait :admin_role do
        after(:create) do |user|
          role = create(:role, name: 'Admin')
          create(:user_role, role: role, user: user)
        end
      end

      trait :user_role do
        after(:create) do |user|
          role = create(:role, name: 'User')
          create(:user_role, role: role, user: user)
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

    factory :role, class: Users::Role do
      name 'test'
      description 'ahahha'
    end

    factory :user_role, class: Users::UserRole do
      association :user
      association :role
    end
end