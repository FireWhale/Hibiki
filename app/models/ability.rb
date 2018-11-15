class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #First, if there isn't a user, make one with language and display settings.

    alias_action :watch, :unwatch, :add_grouping, :collect, :uncollect,
                 to: :user_action #adding to collections and watchlist
    alias_action :edit_profile, :update_profile, :edit_watchlist, :update_watchlist,
                 to: :manage_user #editing profile/watchlist
    alias_action :forgotten_password, :request_password_reset_email, :reset_password_page, :reset_password,
                 to: :reset_passwords
    alias_action :new, :create,
                 to: :login

    #Admin
    can :manage, :all if user.abilities.include?("Admin")

    if user.abilities.include?("User")
      can :user_action, [User]
      can :create, [User]
      can :manage_user, User, id: user.id
      can :destroy, UserSession
    end

    if user.abilities.include?("Advanced Languages")
      can :language, Album
    end

    if user.abilities == ["Any"]
      can :create, [User]
      can :login, [UserSession]
      can :reset_passwords, User
    end

    #Things everyone can do
    if user.abilities.include?("Any")
      can :read, [Album, Artist, Source, Organization, Event, Song, Season]
      can :show_images, [Album, Artist, Source, Organization, Song]
      can :tracklist_export, Album
      can :watchlist, User #looking at someone else's watchlist
      can :collection, User #looking at someone else's collection
      can :show, User #looking at the public profile
      can :read, Issue do |issue|
        user.abilities.include?(issue.visibility)
      end
      can :read, Post do |post|
        user.abilities.include?(post.visibility)
      end
      can :read, Tag do |tag|
        user.abilities.include?(tag.visibility)
      end
    end

  end
end
