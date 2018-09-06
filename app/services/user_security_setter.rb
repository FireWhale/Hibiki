class UserSecuritySetter
  include Performable

  def initialize(user_id,params)
    @user = User.find(user_id)
    @current_roles = @user.user_roles.pluck(:role_id)
    @new_roles = params.fetch(:roles, []).map(&:to_i)
    @new_status = params[:status]
  end

  def perform
    add_roles
    remove_roles
    verify_roles
    add_security
    return @user
  end

  private
    def add_roles
      @new_roles.each do |role_id|
        @user.user_roles.build(role_id: role_id) unless @current_roles.include?(role_id)
      end
    end

    def remove_roles
      @user.user_roles.each do |user_role|
        user_role.mark_for_destruction unless @new_roles.include?(user_role.role_id)
      end
    end

    def verify_roles
      @user.errors.add(:roles, :failed, message: 'Roles do not match input') if @user.user_roles.map(&:role_id).sort == @new_roles.sort
    end

    def add_security
      @user.status = @new_status
    end
end