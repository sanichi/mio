module MassHelper
  def mass_unit_menu
    opts = %w/kg st lb bm/.map { |u| [t("mass.unit.short.#{u}"), u] }
    options_for_select(opts, Mass::DEFAULT_UNIT.key.to_s)
  end

  def mass_months_menu
    opts = [
      ["1m", 1],
      ["2m", 2],
      ["3m", 3],
      ["6m", 6],
      ["1y", 12],
      ["2y", 24],
      ["4y", 48],
      ["6y", 72],
      ["8y", 96],
      ["10y", 120],
      ["All", 0]
    ]
    options_for_select(opts, Mass::DEFAULT_START)
  end
end
