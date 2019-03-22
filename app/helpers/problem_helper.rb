module ProblemHelper
  def problem_level_menu(selected, search: false, new_record: false)
    opts = t("problem.levels").each_with_index.map{ |v, i| [v, i] }
    if search
      opts.unshift [t("any"), ""]
    elsif new_record
      opts.unshift [t("select"), ""]
    end
    options_for_select(opts, selected)
  end

  def problem_category_menu(selected, search: false, new_record: false)
    opts = t("problem.categories", locale: "jp").each_with_index.map{ |v, i| [v, i] }
    if search
      opts.unshift [t("any"), ""]
    elsif new_record
      opts.unshift [t("select"), ""]
    end
    options_for_select(opts, selected)
  end

  def problem_subcategory_menu(selected, search: false, new_record: false)
    opts = t("problem.subcategories", locale: "jp").each_with_index.map{ |v, i| [v, i] }
    if search
      opts.unshift [t("any"), ""]
    elsif new_record
      opts.unshift [t("select"), ""]
    end
    options_for_select(opts, selected)
  end

  def question_solution_menu(selected, new_record)
    opts = [1, 2, 3, 4].map { |s| [s.to_s, s] }
    opts.unshift [t("select"), ""] if new_record
    options_for_select(opts, selected)
  end

  def problem_menu(selected)
    opts = Problem.natural_order.all.map { |p| [p.description, p.id] }
    options_for_select(opts, selected)
  end
end
