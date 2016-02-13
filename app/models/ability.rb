class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can [:read, :tree, :checks, :match, :relative], Person
    can :read, [Blog, Favourite, Picture, Partnership, Tapa]
    can :notes, Tapa
    can [:read, :graph], Mass
    can [:aoc, :pills], Page
  end
end
