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
      can :deeds, :page

    end

    if user.chess?
      can :read, Lesson
      can :read, Tutorial, draft: false
    end

    can :read, [Favourite, Place]
    can [:read, :graph], Mass
    can [:aoc, :play, :premier, :prefectures, :risle, :ruby, :weight], :page
  end
end
