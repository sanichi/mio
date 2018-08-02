class Partnership < ApplicationRecord
  include Constrainable
  include Pageable

  belongs_to :husband, class_name: "Person"
  belongs_to :wife, class_name: "Person"

  MIN_YR = Person::MIN_YR

  validates :divorce, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }, allow_nil: true
  validates :husband_id, :wife_id, presence: true, numericality: { integer_only: true, greater_than: 0 }
  validates :husband_id, uniqueness: { scope: :wife_id }
  validates :wedding, presence: true, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YR }

  validate :years_must_make_sense
  validate :must_be_in_same_domain

  def self.search(params, path, opt={})
    matches = includes(:husband).includes(:wife).order(:wedding)
    if (constraint = numerical_constraint(params[:wedding], :wedding))
      matches = matches.where(constraint)
    end
    if (constraint = cross_constraint(params[:male], %w(last_name first_names known_as married_name), table: "husbands"))
      matches = matches.joins("INNER JOIN people AS husbands ON husbands.id = husband_id").where(constraint)
    end
    if (constraint = cross_constraint(params[:female], %w(last_name first_names known_as married_name), table: "wives"))
      matches = matches.joins("INNER JOIN people AS wives ON wives.id = wife_id").where(constraint)
    end
    matches = matches.where(people: { domain: params[:domain].to_i })
    paginate(matches, params, path, opt)
  end

  def years(plus=false)
    if plus
      divorce ? "#{wedding_plus}-#{divorce_plus}" : wedding_plus
    else
      divorce ? "#{wedding}-#{divorce}" : wedding.to_s
    end
  end

  def wedding_plus
    year_plus(wedding, wedding_guess)
  end

  def divorce_plus
    divorce ? year_plus(divorce, divorce_guess) : nil
  end

  private

  def years_must_make_sense
    errors.add(:wedding, "can't be in the future") if wedding.present? && wedding > Date.today.year
    errors.add(:divorce, "can't be in the future") if divorce.present? && divorce > Date.today.year
    if wedding.present?
      errors.add(:divorce, "can't have divorced before getting married") if divorce.present? && wedding > divorce
      errors.add(:wedding, "can't marry before husband born") if husband.present? && husband.born >= wedding
      errors.add(:born, "can't be marry before wife born") if wife.present? && wife.born >= wedding
    end
  end

  def must_be_in_same_domain
    errors.add(:husband, "must be in same domain") if husband.present? && wife.present? && husband.domain != wife.domain
  end

  def year_plus(year, guess)
    "%d%s" % [year, guess ? "?" : ""]
  end
end
