class UserDefaulter
  include Performable

  def initialize(params)
    @user = User.new(params)
  end

  def perform
    set_role
    set_privacy
    set_language_settings
    set_display_bitmask
    return @user
  end

  private

  def set_role
    role = Users::Role.find_by_name('User')
    @user.roles << role unless role.nil?
  end

  def set_privacy
    @user.privacy = User.get_privacy_bitmask(User::DefaultPrivacySettings)
  end

  def set_language_settings
    @user.language_settings  = User::DefaultLanguages.join(",")
    @user.artist_language_settings  = User::DefaultLanguages.join(",")
  end

  def set_display_bitmask
    @user.display_bitmask = User.get_display_bitmask(User::DefaultDisplaySettings)
  end
end