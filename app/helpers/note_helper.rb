module NoteHelper
  def note_search_order_menu(selected)
    opts = %w/updated created title series/.map { |g| [t("note.#{g}"), g] }
    options_for_select(opts, selected)
  end

  def note_series_menu(selected)
    opts = Note.pluck(:series).uniq.compact.sort.map { |s| [s, s] }
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end
end
