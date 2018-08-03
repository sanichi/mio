module PartnershipHelper
  def partnership_husband_menu(partnership)
    partnership_spouse_menu(partnership, true)
  end

  def partnership_wife_menu(partnership)
    partnership_spouse_menu(partnership, false)
  end

  def partnership_spouse_menu(partnership, male)
    people = Person.order(:last_name, :first_names).where(male: male)
    people = people.where(realm: partnership.realm)
    people = people.where("born < ?", partnership.wedding) if partnership.wedding.present?
    people = people.all.map{ |p| [p.name(reversed: true, with_years: true), p.id] }
    people.unshift [t("select"), ""] if partnership.new_record?
    options_for_select(people, male ? partnership.husband_id : partnership.wife_id)
  end
end
