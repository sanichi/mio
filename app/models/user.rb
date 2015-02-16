class User
  def initialize(type=:guest)
    @type = type.to_sym
  end

  def admin?
    @type == :admin
  end
end
