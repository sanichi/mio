module MassHelper
  def mass_unit_menu
    opts = %w/kg st lb/.map { |u| [t("mass.unit.short.#{u}"), u] }
    options_for_select(opts, Mass::DEFAULT_UNIT.key.to_s)
  end

  def mass_months_menu
    opts = [2, 4, 8, 16, 32, 64].map { |m| [t("mass.options.months", months: m), m] }
    opts.unshift [t("mass.options.month"), 1]
    opts.push [t("mass.options.all"), 0]
    options_for_select(opts, Mass::DEFAULT_START)
  end
end
