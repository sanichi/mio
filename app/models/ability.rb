class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can [:read, :tree, :checks, :match, :relative], Person
    can :read, [Blog, Bucket, Favourite, Picture, Partnership, Tapa]
    can :notes, Tapa
    can [:read, :graph], Mass
    can [:aoc, :pam, :risle, :risle_stats], Page
  end
end
