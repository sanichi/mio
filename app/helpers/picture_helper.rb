module PictureHelper
  def picture_person_menu(picture, i)
    people = Person.order(:last_name, :known_as).all.map{ |p| [p.name(reversed: true, with_years: true), p.id] }
    people.unshift [t("select"), 0]
    person = picture.people[i]
    options_for_select(people, person ? person.id : 0)
  end
end
