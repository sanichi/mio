class Device < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_NAME = 50

  has_many :interfaces

  before_validation :canonicalize

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  def self.search(params, path, opt={})
    matches = ordered
    if (constraint = cross_constraint(params[:q], %w/name notes/))
      matches = matches.where(constraint)
    end
    paginate(matches, params, path, opt)
  end

  def notes_html
    to_html(notes)
  end

  private

  def canonicalize
    name&.squish!
    self.notes = nil if notes.blank?
  end
end
