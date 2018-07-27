class Radical < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_SYMBOL = 1
  MAX_MEANING = 100

  before_validation :truncate

  validates :symbol, presence: true, length: { maximum: MAX_SYMBOL }, uniqueness: true
  validates :meaning, presence: true, length: { maximum: MAX_MEANING }
  validates :level, numericality: { integer_only: true, greater_than_or_equal_to: Vocab::MIN_LEVEL, less_than_or_equal_to: Vocab::MAX_LEVEL }

  scope :by_symbol,  -> { order(Arel.sql('symbol COLLATE "C"')) }
  scope :by_meaning, -> { order(:meaning) }

  def self.search(params, path, opt={})
    params[:q] = params[:qk] if params[:qk].present? # for views/vocabs/_multi_search
    matches = case params[:order]
    when "symbol"   then by_symbol
    else                 by_meaning
    end
    if sql = cross_constraint(params[:q], %w{symbol meaning})
      matches = matches.where(sql)
    end
    if (l = params[:level].to_i) > 0
      matches = matches.where(level: l)
    end
    paginate(matches, params, path, opt)
  end

  private

  def truncate
    self.meaning = meaning&.truncate(MAX_MEANING)
  end
end
