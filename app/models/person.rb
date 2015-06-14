class Person < ActiveRecord::Base
  include Constrainable
  include Pageable
  include Remarkable

  has_many :pictures
  belongs_to :father, class: Person
  belongs_to :mother, class: Person

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
  
  scope :order_by_last_name,  -> { order(:last_name, :first_names, :born) }
  scope :order_by_first_name, -> { order(:first_names, :last_name, :born) }
  scope :order_by_first_born, -> { order(:born, :last_name, :first_names) }
  scope :order_by_known_as,   -> { order(:known_as, :last_name, :born) }

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
    matches = case params[:order]
          when "first" then order_by_first_name
          when "born"  then order_by_first_born
          when "known" then order_by_known_as
          else              order_by_last_name
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
  
  def children
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
end
