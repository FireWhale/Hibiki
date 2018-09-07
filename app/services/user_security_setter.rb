class UserSecuritySetter
  include Performable

  def initialize(user_id,params)
    @user = User.find(user_id)
    @current_roles = @user.user_roles.pluck(:role_id)
    @new_roles = params.fetch(:role_ids, []).map(&:to_i)
    @new_status = params[:status]
  end

  def perform
    add_roles
    remove_roles
    edit_status
    return @user
  end

  private
    def add_roles
      @new_roles.each do |role_id|
        @user.user_roles.build(role_id: role_id) unless @current_roles.include?(role_id) || Users::Role.find_by_id(role_id).nil?
      end
    end

    def remove_roles
      @user.user_roles.each do |user_role|
        user_role.mark_for_destruction unless @new_roles.include?(user_role.role_id)
      end
    end

    def edit_status
      @user.status = @new_status
    end
end