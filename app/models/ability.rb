class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    if user.tree_view?
      can [:read, :tree, :checks], [Person, Picture, Partnership]
    end

    can [:read, :graph], Mass
  end
end
