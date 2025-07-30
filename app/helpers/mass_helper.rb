module MassHelper
  def mass_unit_menu
    opts = %w/kg st lb bm/.map { |u| [t("mass.unit.short.#{u}"), u] }
    options_for_select(opts, Mass::DEFAULT_UNIT.key.to_s)
  end

  def mass_begin_menu
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
    options_for_select(opts, Mass::DEFAULT_BEGIN)
  end

  def mass_end_menu
    years = 2015..Date.today.year
    opts = years.to_a.reverse.map { |y| [y.to_s, y] }
    opts.unshift(["now", 0])
    options_for_select(opts, Mass::DEFAULT_END)
  end
end
