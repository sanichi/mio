class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    if user.chess?
      can :read, Tutorial, draft: false
    end

    if user.isle?
      can [:pam, :risle, :deeds], :page
    end

    can :read, [Favourite, Place]
    can [:read, :graph], Mass
    can [:aoc, :play, :premier, :premier_table, :premier2, :premier2_table, :prefectures, :risle, :ruby, :weight], :page
    can [:read, :checks, :match, :realm, :relative, :set_realm, :tree], Person
    can :read, [Picture, Partnership]
  end
end
