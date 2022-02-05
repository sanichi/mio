module UserHelper
  def user_role_menu(user)
    roles = User::ROLES.map { |role| [t("user.roles.#{role}"), role] }
    roles.unshift [t("select"), ""] if user.new_record?
    options_for_select(roles, user.role.to_s)
  end

  def user_person_menu(user)
    people = Person.order(:last_name, :known_as).where("born > 1915").all.map{ |p| [p.name(reversed: true), p.id] }
    people.unshift [t("none"), 0]
    options_for_select(people, user.person_id)
  end

  def otp_required(user) = t("symbol.#{user.otp_required?       ? 'tick' : 'cross'}")
  def otp_active(user)   = t("symbol.#{user.otp_secret.present? ? 'tick' : 'cross'}")
end
