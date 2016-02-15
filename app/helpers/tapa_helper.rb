module TapaHelper
  def tapa_other_search_menu(selected)
    stars = [
      [t("all"), ""],
      [t("symbol.star"), "star"],
      [t("symbol.note"), "notes"],
    ]
    options_for_select(stars, selected)
  end
end
