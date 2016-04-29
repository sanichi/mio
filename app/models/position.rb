class Position < ActiveRecord::Base
  include Pageable
  include Remarkable

  PIECES = /\A[KQRBNP1-8]{1,8}(\/[KQRBNP1-8]{1,8}){7}\z/i
  ACTIVE = /\A[wb]\z/
  CASTLING = /\A(-|K?Q?k?q?)\z/
  EN_PASSANT = /\A(-|[a-h][36])\z/

  before_validation :normalize_attributes, :check_pieces

  validates :pieces, format: { with: PIECES }, uniqueness: { scope: :active }
  validates :active, format: { with: ACTIVE }
  validates :castling, format: { with: CASTLING }
  validates :en_passant, format: { with: EN_PASSANT }
  validates :half_move, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
  validates :move, numericality: { integer_only: true, greater_than_or_equal_to: 1 }

  def self.search(params)
    matches = matches.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    matches.all
  end

  def fen
    [pieces, active, castling, en_passant, half_move, move].join(" ")
  end

  def notes_html
    to_html(notes)
  end

  private

  def normalize_attributes
    self.pieces = pieces.to_s.split(//).select{ |x| x =~ /\A[KQRBNP1-8\/]\z/i }.join("")
    self.active = active.to_s.split(//).select{ |x| x =~ /\A[wb]\z/i }.uniq.map(&:downcase).join("")
    self.castling = castling.to_s.split(//).select{ |x| x =~ /\A[kq]\z/i }.uniq.sort.join("")
    self.en_passant = en_passant.to_s.split(//).select{ |x| x =~ /\A[a-h36]\z/i }.map(&:downcase).join("")
    self.castling = "-" if castling.blank?
    self.en_passant = "-" if en_passant.blank?
    self.half_move = 0 if half_move.blank?
    self.move = 1 if move.blank? || move == 0
    self.notes = nil unless notes.present?
  end

  def check_pieces
    err = nil
    err = I18n.t("position.error.badc") unless err || pieces.split(//).map{ |p| p.match(/\A[1-8\/]\z/) ? p.to_i : 1 }.sum == 64
    err = I18n.t("position.error.nobk") unless err || pieces.match(/k/)
    err = I18n.t("position.error.nowk") unless err || pieces.match(/K/)
    err = I18n.t("position.error.tmbk") unless err || pieces.scan("k").size == 1
    err = I18n.t("position.error.tmwk") unless err || pieces.scan("K").size == 1
    err = I18n.t("position.error.pote") unless err || !pieces.match(/\A[^\/]*p/i)
    err = I18n.t("position.error.potf") unless err || !pieces.match(/p[^\/]*\z/i)
    errors.add(:pieces, err) if err
  end
end
