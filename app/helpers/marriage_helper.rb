module MarriageHelper
  def marriage_husband_menu(marriage)
    marriage_spouse_menu(marriage, true)
  end

  def marriage_wife_menu(marriage)
    marriage_spouse_menu(marriage, false)
  end

  def marriage_spouse_menu(marriage, gender)
    people = Person.order(:last_name, :first_names).where(gender: gender)
    people = people.where("born < ?", marriage.wedding) if marriage.wedding.present?
    people = people.all.map{ |p| [p.name(reversed: true), p.id] }
    people.unshift [t("select"), ""] if marriage.new_record?
    options_for_select(people, gender ? marriage.husband_id : marriage.wife_id)
  end
end
