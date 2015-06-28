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

  validate :years_must_make_sense, :parents_must_make_sense

  scope :by_last_name,  -> { order(:last_name, :first_names, :born) }
  scope :by_first_name, -> { order(:first_names, :last_name, :born) }
  scope :by_born, -> { order(:born, :last_name, :first_names) }
  scope :by_known_as,   -> { order(:known_as, :last_name, :born) }

  def name(full: true, reversed: false, with_known_as: true)
    first = full ? first_names : known_as
    first+= " (#{known_as})" if full && with_known_as && !first_names.split(" ").include?(known_as)
    reversed ? "#{last_name}, #{first}" : "#{first} #{last_name}"
  end

  def years
    born || died ? "#{born}-#{died}" : ""
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
    matches = matches.where("last_name ILIKE ?", "%#{params[:last_name]}%") if params[:last_name].present?
    if params[:first_names].present?
      pattern = "%#{params[:first_names]}%"
      matches = matches.where("first_names ILIKE ? OR known_as ILIKE ?", pattern, pattern)
    end
    constraint = constraint(params[:born], :born)
    matches = matches.where(constraint) if constraint
    matches = matches.where(male: true) if params[:gender] == "male"
    matches = matches.where(male: false) if params[:gender] == "female"
    matches = matches.where("notes ILIKE ?", "%#{params[:notes]}%") if params[:notes].present?
    paginate(matches, params, path, opt)
  end

  def self.match(term)
    return [] unless term.present?
    clause = %w(last_name first_names known_as).map{ |c| "#{c} ILIKE ?"}.join(" OR ")
    values = Array.new(3, "%#{term}%")
    by_last_name.where(clause, *values).map do |person|
      { id: person.id, value: person.name(reversed: true) }
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
    return @partners if @partners
    join = "INNER JOIN partnerships ON #{male ? 'husband' : 'wife'}_id = #{id} AND #{male ? 'wife' : 'husband'}_id = people.id"
    @partners = Person.joins(join).order("wedding")
  end

  Ancestor = Struct.new(:person, :connection, :waiting)
  def ancestors
    @ancestors ||= complete({id => Ancestor.new(self, [], true)})
  end

  def relationship(other)
    return Relation.new(:self) if self == other
    my_connections, their_connections = common(ancestors, other.ancestors)
    Relation.infer(my_connections, their_connections, male)
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
      person, connection = ancestor.person, ancestor.connection
      if father = person.father
        ancestors[father.id] ||= Ancestor.new(father, connection + [:father], true)
      end
      if mother = person.mother
        ancestors[mother.id] ||= Ancestor.new(mother, connection + [:mother], true)
      end
      ancestor.waiting = false
    end
    waiting.any?? complete(ancestors) : ancestors
  end

  def common(mine, theirs)
    common_ids = Set.new(mine.keys) & Set.new(theirs.keys)
    [mine, theirs].map do |ancestors|
      connections = common_ids.map{ |id| ancestors[id] }.map(&:connection)
      min = connections.map(&:size).min
      connections.select{ |connection| connection.size == min }
    end
  end
end
