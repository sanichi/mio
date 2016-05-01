class Opening < ActiveRecord::Base
  include Constrainable
  include Pageable

  MAX_DESC = 255

  validates :code, format: { with: /\A[A-E]\d\d\z/ }, uniqueness: true
  validates :description, length: { maximum: MAX_DESC }, presence: true

  scope :by_code, -> { order(:code) }

  def self.search(params, path, opt={})
    sql = nil
    matches = by_code
    matches = matches.where(sql) if sql = cross_constraint(params[:q], cols: %w{code description})
    paginate(matches, params, path, opt)
  end

  def desc(max: 64)
    "#{code} #{description.truncate(max - 4)}"
  end
end
