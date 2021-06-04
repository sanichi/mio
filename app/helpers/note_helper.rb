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

  def note_series_list
    Note.pluck(:series).uniq.compact.sort
  end

  def note_number_menu(note)
    opts = Note.where(series: note.series).order(:number).where.not(id: note.id).map do |n|
      [n.ntitle, n.number]
    end
    opts.push([t("note.last"), -1])
    options_for_select(opts, note.number)
  end
end
