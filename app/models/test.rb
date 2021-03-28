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

  scope :inner, ->(table,type) { joins("INNER JOIN #{table} AS t1 ON testable_id = t1.id AND testable_type = '#{type}'") }
  scope :inner_example, -> { inner("wk_examples", "Wk::Example") }
  scope :inner_border, -> { inner("borders", "Border").joins("INNER JOIN places AS t2 ON t1.from_id = t2.id") }
  scope :inner_place, -> { inner("places", "Place") }
  scope :place_level, ->(level) { where("places.category IN (?)", Place::CATS.select{|t,l| l == level}.keys) }
  scope :match_example, ->(filter) do
    if sql = cross_constraint(filter, %w/english japanese/, table: "t1")
      inner_example.where(sql)
    else
      where(testable_type: "Wk::Example")
    end
  end
  scope :match_border, ->(filter) do
    if sql = cross_constraint(filter, %w/ename jname/, table: "t2")
      inner_border.where(sql)
    else
      where(testable_type: "Border")
    end
  end
  scope :match_place, ->(filter,level=nil) do
    sql = cross_constraint(filter, %w/ename jname/, table: "t1")
    if sql && level
      inner_place.place_level(level).where(sql)
    elsif level
      inner_place.place_level(level)
    elsif sql
      inner_place.where(sql)
    else
      where(testable_type: "Place")
    end
  end

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "new"
        where(attempts: 0)
      when "today"
        where("due > ?", Time.now).where("due < ?", Time.now + 1.day).order(due: :asc)
      when "week"
        where("due > ?", Time.now).where("due < ?", Time.now + 1.week).order(due: :asc)
      when "best"
        where("attempts > 0").order(level: :desc, attempts: :asc)
      when "worst"
        where("attempts > 0").order(attempts: :desc, level: :asc)
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
        matches.match_example(params[:filter])
      when "place"
        matches.match_place(params[:filter])
      when "border"
        matches.match_border(params[:filter])
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
