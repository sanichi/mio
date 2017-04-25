module VocabHelper
  def vocab_search_order_menu(selected)
    ords = []
    %w/kana meaning/.each { |g| ords.push [t("vocab.#{g}"), g] }
    options_for_select(ords, selected)
  end
end
