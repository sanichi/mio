module TodoHelper
  def todo_priority_menu(selected, top=nil)
    trns = t("todo.priorities")
    pris = Todo::PRIORITIES.map { |p| [trns[p], p] }
    pris.unshift [t(top), ""] if top.present?
    options_for_select(pris, selected)
  end
end
