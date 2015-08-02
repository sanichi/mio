module PictureHelper
  def picture_person_menu(picture)
    people = Person.order(:last_name, :known_as).all.map{ |p| [p.name(reversed: true, with_years: true), p.id] }
    people.unshift [t("select"), 0]
    options_for_select(people, picture.person_id)
  end
end
