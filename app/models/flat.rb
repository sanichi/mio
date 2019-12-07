class Flat < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  BAYS = (1..90).to_a
  BLOCKS = (1..23).to_a
  BUILDINGS = (5..21).to_a
  NUMBERS = (1..9).to_a
  CATEGORIES = %w/A A1 A2 A3 A4 B B1 B2 BM B-upper C C1 CM E E1 G P1 P2 P3/
  NAMES = %w/Albany Clofars Comet Concord Dart Eagle Fortune Gallery Hopewill Leith Penthouse Raith Rohilla Ronan Salamander Sirius Unicorn/

  before_validation :canonicalize

  validates :bay, inclusion: { in: BAYS }, uniqueness: true, allow_nil: true
  validates :block, inclusion: { in: BLOCKS }
  validates :building, inclusion: { in: BUILDINGS }
  validates :number, inclusion: { in: NUMBERS }, uniqueness: { scope: :building }, allow_nil: true
  validates :name, inclusion: { in: NAMES }
  validates :category, inclusion: { in: CATEGORIES }

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

  # Turn block/number to bay or bay to block/number.
  def self.pam(q)
    answer = nil
    if q =~ /\A\s*([1-9]\d*)\D+(\d*)\s*\z/
      building = $1.to_i
      number = $2.to_i
      flats = Flat.where(building: building).to_a
      flat = case flats.size
      when 0
        nil
      when 1
        flats.first
      else
        Flat.find_by building: building, number: number
      end
      if flat
        answer = flat.bay.present?? "#{flat.address} → #{flat.bay}" : "#{flat.address} → none"
      end
    elsif q =~ /\A\s*([1-9]\d*)\s*\z/
      bay = $1.to_i
      flat = Flat.find_by bay: bay
      if flat
        answer = "#{bay} ← #{flat.address}"
      end
    end
    answer
  end

  def address
    [building, number].compact.join("/")
  end

  def notes_html
    to_html(notes)
  end

  private

  def canonicalize
    self.notes = nil if notes.blank?
  end
end
