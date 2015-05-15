class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can [:read, :graph], Mass
    can :read, Fund
  end
end
