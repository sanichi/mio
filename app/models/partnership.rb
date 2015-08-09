class Partnership < ActiveRecord::Base
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

  def self.search(params, path, opt={})
    matches = includes(:husband).includes(:wife).order(:wedding)
    if (constraint = numerical_constraint(params[:wedding], :wedding))
      matches = matches.where(constraint)
    end
    if (constraint = cross_constraint(params[:male], table: "husbands"))
      matches = matches.joins("INNER JOIN people AS husbands ON husbands.id = husband_id").where(constraint)
    end
    if (constraint = cross_constraint(params[:female], table: "wives"))
      matches = matches.joins("INNER JOIN people AS wives ON wives.id = wife_id").where(constraint)
    end
    paginate(matches, params, path, opt)
  end

  def years
    divorce ? "#{wedding}-#{divorce}" : wedding.to_s
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
end
