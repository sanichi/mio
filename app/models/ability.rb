class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can [:read, :tree, :checks], Person
    can :read, [Picture, Partnership]
    can [:read, :graph], Mass
  end
end
