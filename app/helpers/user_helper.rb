module UserHelper
  def user_role_menu(user)
    roles = User::ROLES.map { |role| [t("user.roles.#{role}"), role] }
    roles.unshift [t("select"), ""] if user.new_record?
    options_for_select(roles, user.role.to_s)
  end
end
