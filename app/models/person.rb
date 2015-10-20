class Person < ActiveRecord::Base
  include Constrainable
  include Pageable
  include Remarkable

  has_many :pictures
  belongs_to :father, class_name: "Person"
  belongs_to :mother, class_name: "Person"

  MAX_FN = 100
  MAX_KA = 20
  MAX_LN = 50
  MIN_YR = 1600

  before_validation :tidy_text

  validates :born, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }
  validates :died, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }, allow_nil: true
  validates :father_id, :mother_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true
  validates :first_names, presence: true, length: { maximum: MAX_FN }
  validates :known_as, presence: true, length: { maximum: MAX_KA }
  validates :last_name, presence: true, length: { maximum: MAX_LN }
  validates :married_name, length: { maximum: MAX_LN }, allow_nil: true

  validate :years_must_make_sense, :parents_must_make_sense

  scope :by_last_name,  -> { order(:last_name, :first_names, :born) }
  scope :by_first_name, -> { order(:first_names, :last_name, :born) }
  scope :by_born, -> { order(:born, :last_name, :first_names) }
  scope :by_known_as,   -> { order(:known_as, :last_name, :born) }

  def name(full: true, reversed: false, with_known_as: true, with_years: false, with_married_name: false)
    fn = full ? first_names : known_as
    fn += " (#{known_as})" if full && with_known_as && !first_names.split(" ").include?(known_as)
    ln = last_name + (with_married_name && married_name.present? && married_name != last_name ? " (#{married_name})" : "")
    years = with_years && born ? (died ? " #{born}-#{died}" : " #{born}") : ""
    (reversed ? "#{ln}, #{fn}" : "#{fn} #{ln}") + years
  end

  def years(plus: false)
    b = plus ? born_plus : born
    d = plus ? died_plus : died
    "#{b}-#{d}"
  end

  def born_plus
    year_plus(born, born_guess)
  end

  def died_plus
    died ? year_plus(died, died_guess) : nil
  end

  def notes_html
    to_html(notes)
  end

  def self.search(params, path, opt={})
    matches =
    case params[:order]
    when "first" then by_first_name
    when "born"  then by_born
    when "known" then by_known_as
    else              by_last_name
    end
    sql = nil
    matches = matches.where(sql) if (sql = cross_constraint(params[:name]))
    matches = matches.where(sql) if (sql = cross_constraint(params[:notes], cols: ["notes"]))
    matches = matches.where(sql) if (sql = numerical_constraint(params[:born], :born))
    matches = matches.where(sql) if (sql = numerical_constraint(params[:died], :died))
    matches = matches.where(male: true) if params[:gender] == "male"
    matches = matches.where(male: false) if params[:gender] == "female"
    paginate(matches, params, path, opt)
  end

  def self.match(params)
    sql = cross_constraint(params[:term])
    return [] unless sql
    matches = where(sql)
    matches = matches.where(male: true)  if params[:gender] == "male"
    matches = matches.where(male: false) if params[:gender] == "female"
    matches = matches.where("born < #{params[:max_born].to_i}") if params[:max_born].to_i > 0
    matches.by_last_name.map do |person|
      { id: person.id, value: person.name(reversed: true, with_years: true, with_married_name: true) }
    end
  end

  def children
    @children ||= Person.by_born.where("#{male ? 'father' : 'mother'}_id = #{id}")
  end

  def siblings
    return [] unless father_id || mother_id
    return @siblings if @siblings
    clauses = []
    clauses.push("father_id = #{father_id}") if father_id
    clauses.push("mother_id = #{mother_id}") if mother_id
    @siblings = Person.by_born.where(clauses.join(" OR ")).where.not(id: id)
  end

  def partners
    @partners ||= partnerships.map { |p| p.send(male ? :wife : :husband) }
  end

  def partnerships
    @partnerships ||= Partnership.where("#{male ? 'husband' : 'wife'}_id = #{id}").order(:wedding)
  end

  Ancestor = Struct.new(:person, :depth, :width, :order, :waiting)

  def ancestors
    @ancestors ||= complete({id => Ancestor.new(self, 0, 0, "", true)})
  end

  def relationship(other)
    return Relation.new(:self) if self == other
    my_ancestor, their_ancestor = best_common_ancestor(other)
    Relation.infer(my_ancestor, their_ancestor, male)
  end

  def tree_hash(focus=false)
    h = Hash.new
    if focus
      h[:person] = tree_hash
      h[:father] = father.try(:tree_hash)
      h[:mother] = mother.try(:tree_hash)
      h[:families] = tree_families
    else
      h[:id] = id
      h[:name] = name(full: false, with_known_as: true).gsub(/ /, "&nbsp;")
      h[:years] = years(plus: true)
      h[:picture] = sample_portrait_path
    end
    h
  end

  private

  def tidy_text
    %w[first_names known_as last_name].each { |m| send("#{m}=", "") if send(m).nil? }
    last_name.squish!
    first_names.squish!
    known_as.squish!
    if known_as.blank? && first_names.present?
      self.known_as = first_names.split(" ").first
    end
    self.notes = nil if notes.blank?
    if male || married_name.blank?
      self.married_name = nil
    else
      married_name.squish!
    end
  end

  def years_must_make_sense
    errors.add(:born, "can't be in the future") if born.present? && born > Date.today.year
    errors.add(:died, "can't be in the future") if died.present? && died > Date.today.year
    if born.present?
      errors.add(:died, "can't have died before being born") if died.present? && born > died
      errors.add(:born, "can't be born before father") if father.present? && father.born >= born
      errors.add(:born, "can't be born before mother") if mother.present? && mother.born >= born
    end
  end

  def parents_must_make_sense
    errors.add(:father_id, "can't be female") if father.present? && !father.male
    errors.add(:mother_id, "can't be male") if mother.present? && mother.male
  end

  def complete(ancestors)
    (waiting = ancestors.values.select(&:waiting)).each do |ancestor|
      person, width, depth, order = ancestor.person, ancestor.width, ancestor.depth, ancestor.order
      if father = person.father
        ancestors[father.id] ||= Ancestor.new(father, depth + 1, width, order + "P", true)
      end
      if mother = person.mother
        ancestors[mother.id] ||= Ancestor.new(mother, depth + 1, width, order + "P", true)
      end
      if person.partners.any?
        person.partners.each do |partner|
          ancestors[partner.id] ||= Ancestor.new(partner, depth, width + 1, order + "M", true)
        end
      end
      ancestor.waiting = false
    end
    waiting.any?? complete(ancestors) : ancestors
  end

  def best_common_ancestor(other)
    mine = ancestors
    theirs = other.ancestors
    common_ids = Set.new(mine.keys) & Set.new(theirs.keys)
    return [nil, nil] if common_ids.empty?
    my_best = common_ids.map do |id|
      ancestors[id]
    end.sort do |a,b|
      a.depth == b.depth ? a.width <=> b.width : a.depth <=> b.depth
    end.first
    their_best = theirs[my_best.person.id]
    [my_best, their_best]
  end

  def tree_families
    hash = Hash.new { |h, k| h[k] = Array.new }
    children.each { |c| hash[c.send(male?? :mother : :father)].push(c) }
    partners.each { |p| hash[p] }
    hash.each_pair.each_with_object([]) do |(partner, children), array|
      family = Hash.new
      family[:partner] = partner.try(:tree_hash)
      family[:children] = children.sort_by(&:born).map(&:tree_hash)
      array.push family
    end
  end

  def year_plus(year, guess)
    "%d%s" % [year, guess ? "?" : ""]
  end

  def sample_portrait_path
    sample = pictures.where(portrait: true).sample
    sample ? sample.image.url(:tn) : "/system/images/blank_#{male ? '' : 'wo'}man.png"
  end
end
