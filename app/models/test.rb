class Test < ApplicationRecord
  include Pageable
  include Constrainable

  MAX_LEVEL = 9
  MIN_LEVEL = 0
  ANSWERS = %w/poor fair good excellent skip/

  belongs_to :testable, polymorphic: true

  after_update :update_stats

  validates :attempts, :poor, :fair, :good, :excellent, numericality: { integer_only: true, more_than_or_equal_to: 0 }
  validates :level, numericality: { integer_only: true, more_than_or_equal_to: MIN_LEVEL, less_than_or_equal_to: MAX_LEVEL }
  validates :last, inclusion: { in: ANSWERS }, allow_nil: true

  scope :inner_example, -> { joins("INNER JOIN wk_examples ON testable_id = wk_examples.id AND testable_type = 'Wk::Example'") }
  scope :inner_place, -> { joins("INNER JOIN places ON testable_id = places.id AND testable_type = 'Place'") }
  scope :place_level, ->(level) { where("places.category IN (?)", Place::CATS.select{|t,l| l == level}.keys) }
  scope :match_place, ->(filter, level=nil) do
    sql = cross_constraint(filter, %w/ename jname/, table: "places")
    if sql && level
      inner_place.place_level(level).where(sql)
    elsif level
      inner_place.place_level(level)
    elsif sql
      inner_place.inner_place.where(sql)
    else
      where(testable_type: "Place")
    end
  end
  scope :match_example, ->(filter) do
    if sql = cross_constraint(filter, %w/english japanese/, table: "wk_examples")
      inner_example.where(sql)
    else
      where(testable_type: "Wk::Example")
    end
  end

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "new"
        where(due: nil)
      when "today"
        where("due > ?", Time.now).where("due < ?", Time.now + 1.day).order(due: :asc)
      when "week"
        where("due > ?", Time.now).where("due < ?", Time.now + 1.week).order(due: :asc)
      when "attempts"
        order(attempts: :desc)
      when "skipped"
        where(last: "skip").order(due: :asc)
      when "updated"
        order(updated_at: :desc)
      else
        where("due < ?", Time.now).order(due: :asc)
      end
    matches =
      case params[:type]
      when "example"
        match_example(params[:filter])
      when "place"
        matches.match_place(params[:filter])
      when "border"
        matches.where(testable_type: "Border")
      when "region"
        matches.match_place(params[:filter], 0)
      when "prefecture"
        matches.match_place(params[:filter], 1)
      when "city"
        matches.match_place(params[:filter], 2)
      else
        matches
      end
    matches = matches.where(last: params[:last]) if ANSWERS.include? params[:last]
    paginate(matches, params, path, opt)
  end

  private

  def update_stats
    return unless ANSWERS.include?(last)
    return if last == "skip"
    update_column(:attempts, attempts + 1)
    update_column(last, send(last) + 1)
    update_level
    update_due
  end

  def update_level
    new_level = level
    case last
    when "poor"
      new_level -= 2
    when "fair"
      new_level -= 1
    when "good"
      new_level += 1
    when "excellent"
      new_level += 2
    end
    new_level = MIN_LEVEL if new_level < MIN_LEVEL
    new_level = MAX_LEVEL if new_level > MAX_LEVEL
    update_column(:level, new_level)
  end

  def update_due
    new_due = Time.now
    case level
    when 0
      new_due += 12.hours
    when 1
      new_due += 1.day
    when 2
      new_due += 2.days
    when 3
      new_due += 4.days
    when 4
      new_due += 8.days
    when 5
      new_due += 16.days
    when 6
      new_due += 1.month
    when 7
      new_due += 2.months
    when 8
      new_due += 3.months
    when 9
      new_due += 4.months
    end
    update_column(:due, new_due)
  end
end
