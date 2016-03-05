class Flat < ActiveRecord::Base
  include Constrainable
  include Pageable

  BAYS = (1..90).to_a
  BLOCKS = (1..23).to_a
  BUILDINGS = (5..21).to_a
  NUMBERS = (1..9).to_a
  CATEGORIES = %w/A A1 A2 A3 A4 B B1 B2 BM B-upper C C1 CM E E1 P1 P2 P3/
  NAMES = %w/Albany Clofars Comet Concord Dart Eagle Fortune Hopewill Leith Penthouse Raith Rohilla Ronan Salamander Sirius Unicorn/

  belongs_to :owner, class_name: "Resident", foreign_key: "owner_id"
  belongs_to :tenant, class_name: "Resident", foreign_key: "tenant_id"

  validates :bay, inclusion: { in: BAYS }, uniqueness: true
  validates :block, inclusion: { in: BLOCKS }
  validates :building, inclusion: { in: BUILDINGS }
  validates :number, inclusion: { in: NUMBERS }, uniqueness: { scope: :building }, allow_nil: true
  validates :name, inclusion: { in: NAMES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :owner_id, :tenant_id, numericality: { integer_only: true, greater_than: 0 }, allow_nil: true

  validate :tenant_cant_be_owner

  scope :by_address,  -> { order(:building, :number) }
  scope :by_bay,      -> { order(:bay, :building, :number) }
  scope :by_block,    -> { order(:block, :building, :number) }
  scope :by_category, -> { order(:category, :name, :building, :number) }
  scope :by_name,     -> { order(:name, :category, :building, :number) }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "bay"      then by_bay
    when "block"    then by_block
    when "category" then by_category
    when "name"     then by_name
    else                 by_address
    end
    matches = matches.includes(:owner).includes(:tenant)
    %i/building number block bay/.each do |k|
      if sql = numerical_constraint(params[k], k)
        matches = matches.where(sql)
      end
    end
    if (q = params[:category]).present?
      matches = matches.where("category ILIKE ?", "%#{q}%")
    end
    if (q = params[:name]).present?
      matches = matches.where("name ILIKE ?", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  def address
    [building, number].compact.join("/")
  end

  private

  def tenant_cant_be_owner
    if owner_id.present? and tenant_id == owner_id
      errors.add(:tenant_id, "tenant can't be owner")
    end
  end
end
