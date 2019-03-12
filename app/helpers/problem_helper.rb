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
end
