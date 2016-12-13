class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    if user.risle?
      can :read, [Flat, Parking, Resident, Vehicle]
      can :deeds, Page
    end

    can [:read, :tree, :checks, :match, :relative], Person
    can :read, [Blog, Bucket, Favourite, Picture, Partnership, Tapa]
    can :notes, Tapa
    can [:read, :graph], Mass
    can [:aoc, :risle, :risle_stats], Page
  end
end
