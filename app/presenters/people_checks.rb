class PeopleChecks
  def people_guessed_year_born
    Person.by_last_name.where(born_guess: true).all
  end

  def people_guessed_year_died
    Person.by_last_name.where(died_guess: true).all
  end

  def people_unknown_year_died
    cut_off = Date.today.year - 95
    Person.by_last_name.where(died: nil).select do|person|
      person.born < cut_off
    end
  end

  def people_unknown_maiden_name
    Person.by_last_name.where(male: false).where.not(married_name: nil).select do|person|
      person.last_name == person.married_name
    end
  end

  def people_males_with_maiden_name
    Person.by_last_name.where(male: true).where.not(married_name: nil).all
  end

  def people_males_with_female_name
    Person.by_last_name.where(male: true).select do|person|
      person.first_names.match(/\b(aaa
        |Agnes|Alena|Alexandra|Alice|Ann(e|ie)?|Anna(belle)?|Arlene
        |Carmen|Carol(ina)?|Catherine|Colina|Colleen
        |Deborah|Dorothy
        |Edith|Elizabeth|Elsie|Emerie
        |Fanny|Faye|Francis
        |Grace
        |Hannah|Helen|Hester
        |Irene|Isabella|Isobel|Ivy
        |Jane|Janet|Jean|Jeanie|Johanna|Julia|June
        |Kat(e|herine|ie)|Kathleen
        |Louisa|Louise
        |Lynds(a|e|)y
        |Margaret|Margretta|Marjorie|Mary|Maud|Maureen|Mona
        |Norah
        |Olive
        |Patricia|Paula|Penelope
        |Roberta|Rosemary|Ruth
        |Sandra|Sarah|Sheena
        |Trace?y
        |Victoria
        |Winni(e|fred)?
      )\b/ix)
    end
  end

  def people_females_with_male_name
    Person.by_last_name.where(male: false).select do|person|
      person.first_names.match(/\b(aaa
        |Albert|Alexander|Alistair|Archi(bald|e)|Arthur
        |Bill|Bruce
        |Chamath|Charl(es|ie)|Colin|Cyril
        |Dave|David|Doug(ie|las)?
        |Fred(erick)?
        |George
        |Har(old|ry)|Henry|Hugh
        |Ian|Iain
        |Jackey|Jake|James|Jim(my)?|Joe|John|Joseph
        |Karl|Ken|Ken(neth)?|Kerr|Kirk
        |Leandro
        |Malcolm|Mark|Martin
        |Nathan|Neil|Nigel
        |Peter
        |Richard|Robert|Robin|Ross
        |Samuel|Scott|Simon|Stephen|Steven?|Stuart
        |Terr(ence|y)|Thomas|Tom
        |Walter|William
      )\b/ix)
    end
  end

  def partners_missing
    need = Person.includes(:father, :mother).each_with_object({}) do |p, h|
      if p.father && p.mother
        h["#{p.father.id}-#{p.mother.id}"] = Partnership.new(husband: p.father, wife: p.mother)
      end
    end
    Partnership.includes(:husband, :wife).each do |p|
      need.delete("#{p.husband.id}-#{p.wife.id}")
    end
    need.values
  end

  def partners_guessed_year_wedding
    Partnership.order(:wedding).where(wedding_guess: true).all
  end

  def partners_guessed_year_divorce
    Partnership.order(:wedding).where.not(divorce: nil).where(divorce_guess: true).all
  end
end
