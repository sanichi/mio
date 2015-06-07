module PersonHelper
  def person_gender_search_menu(selected)
    gens = []
    gens.push [t("either"), ""]
    %w/male female/.each { |g| gens.push [t("person.#{g}"), g] }
    options_for_select(gens, selected)
  end

  def person_search_order_menu(selected)
    ords = []
    %w/last first born/.each { |g| ords.push [t("person.order.#{g}"), g] }
    options_for_select(ords, selected)
  end
end
