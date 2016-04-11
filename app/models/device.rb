class Device < ActiveRecord::Base
  include Constrainable
  include Pageable
  include Remarkable

  MAX_MFTR = 50
  MAX_NNAM = 50
  MAX_RNAM = 50

  has_many :interfaces

  before_validation :canonicalize

  validates :network_name, presence: true

  scope :ordered, -> { order(:network_name) }

  def self.search(params, path, opt={})
    matches = ordered
    if (constraint = cross_constraint(params[:q], cols: %w/network_name real_name manufacturer/))
      matches = matches.where(constraint)
    end
    paginate(matches, params, path, opt)
  end

  def notes_html
    to_html(notes)
  end

  private

  def canonicalize
    manufacturer&.squish!
    network_name&.squish!
    real_name&.squish!
    self.manufacturer = nil if manufacturer.blank?
    self.notes = nil if notes.blank?
    self.real_name = nil if real_name.blank?
  end
end
