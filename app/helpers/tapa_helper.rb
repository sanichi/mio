module TapaHelper
  def tapa_star_search_menu(selected)
    stars = [
      [t("any"), ""],
      [t("symbol.star"), "1"],
    ]
    options_for_select(stars, selected)
  end
end
