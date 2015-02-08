class MassUnit
  attr_reader :key, :name

  def initialize(key, factor, decimals, delta)
    @key      = key
    @name     = I18n.t("mass.unit.#{key}")
    @factor   = factor
    @decimals = decimals
    @delta    = delta
  end

  def to_f(mass)
    @factor * mass if mass
  end

  def to_s(mass)
    "%.#{@decimals}f" % to_f(mass) if mass
  end

  def ticks(min, max)
    if min.blank? || max.blank? || min >= max
      min = to_f(Mass::MIN_KG)
      max = to_f(Mass::MAX_KG)
    end
    min = (min / @delta).floor
    max = (max / @delta).ceil
    min.upto(max).map { |t| t * @delta }
  end
end
