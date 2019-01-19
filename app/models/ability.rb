class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      return
    end

    can :manage, Book if user.books?

    if !user.guest? && !user.books? # anyone logged in except for book people
      can [:read, :tree, :checks, :match, :relative], Person
      can :read, [Picture, Partnership]
    end

    can :read, [Blog, Book, Bucket, Dragon, Favourite, Tapa]
    can :notes, Tapa
    can [:read, :graph], Mass
    can [:aoc, :pam, :risle, :risle_stats, :tribute], Page
  end
end
