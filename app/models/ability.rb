class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can [:read, :tree, :checks, :match, :relative], Person
    can :read, [Blog, Picture, Partnership, Favourite]
    can [:read, :graph], Mass
  end
end
