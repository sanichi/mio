module NoteHelper
  def note_search_order_menu(selected)
    opts = %w/updated created title/.map { |g| [t("vocab.note.#{g}"), g] }
    options_for_select(opts, selected)
  end
end
