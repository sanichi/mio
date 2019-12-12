class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    if user.family?
      can [:read, :tree, :checks, :match, :relative], Person
      can :read, [Picture, Partnership]
    end

    can :read, [Bucket, Favourite]
    can [:read, :graph], Mass
    can [:aoc, :pam, :risle, :risle_stats], Page
  end
end
