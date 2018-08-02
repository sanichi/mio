module PersonHelper
  def person_gender_search_menu(selected)
    gens = []
    gens.push [t("both"), ""]
    %w/male female/.each { |g| gens.push [t("person.#{g}"), g] }
    options_for_select(gens, selected)
  end

  def person_search_order_menu(selected)
    ords = []
    %w/last first known born/.each { |g| ords.push [t("person.order.#{g}"), g] }
    options_for_select(ords, selected)
  end

  def person_realm_menu(selected)
    opts = Person::MIN_REALM.upto(Person::MAX_REALM).map { |d| [ t("person.realms")[d], d.to_s ] }
    options_for_select(opts, selected)
  end

  def person_father_menu(person)
    person_parent_menu(person, true)
  end

  def person_mother_menu(person)
    person_parent_menu(person, false)
  end

  def person_parent_menu(person, male)
    people = Person.order(:last_name, :first_names).where(male: male)
    people = people.where(realm: person.realm) unless person.new_record?
    people = people.where("born < ?", person.born) if person.born.present?
    people = people.where(last_name: person.last_name) if male && person.male && person.last_name.present?
    people = people.all.map{ |p| [p.name(reversed: true, with_years: true, with_married_name: true), p.id] }
    people.unshift [t("unknown"), ""]
    options_for_select(people, male ? person.father_id : person.mother_id)
  end
end
