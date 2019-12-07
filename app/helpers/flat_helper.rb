module FlatHelper
  def flat_bay_menu(flat)
    opt = Flat::BAYS.map { |b| [b, b] }
    opt.unshift [t("none"), ""]
    options_for_select(opt, flat.bay)
  end

  def flat_block_menu(flat)
    opt = Flat::BLOCKS.map { |b| [b, b] }
    opt.unshift [t("select"), ""]
    options_for_select(opt, flat.block)
  end

  def flat_building_menu(flat)
    opt = Flat::BUILDINGS.map { |b| [b, b] }
    opt.unshift [t("select"), ""]
    options_for_select(opt, flat.building)
  end

  def flat_number_menu(flat)
    opt = Flat::NUMBERS.map { |n| [n, n] }
    opt.unshift [t("none"), ""]
    options_for_select(opt, flat.number)
  end

  def flat_category_menu(flat)
    opt = Flat::CATEGORIES.map { |c| [c, c] }
    opt.unshift [t("select"), ""]
    options_for_select(opt, flat.category)
  end

  def flat_name_menu(flat)
    opt = Flat::NAMES.map { |n| [n, n] }
    opt.unshift [t("select"), ""]
    options_for_select(opt, flat.name)
  end

  def flat_search_order_menu(order)
    opt = %w/address block bay category name/.map { |o| [I18n.t("flat.#{o}"), o] }
    options_for_select(opt, order)
  end
end
