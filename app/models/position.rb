class Position < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  PIECES = /\A[KQRBNP1-8]{1,8}(\/[KQRBNP1-8]{1,8}){7}\z/i
  ACTIVE = /\A[wb]\z/
  CASTLING = /\A(-|K?Q?k?q?)\z/
  EN_PASSANT = /\A(-|[a-h][36])\z/
  MAX_NAME = 255
  SYMBOL = { "K" => "♔", "Q" => "♕", "B" => "♗", "N" => "♘", "R" => "♖" }

  belongs_to :opening

  before_validation :split_fen, :normalize_attributes, :check_pieces, :proxy_symbols

  validates :pieces, format: { with: PIECES }, uniqueness: { scope: :active }
  validates :active, format: { with: ACTIVE }
  validates :castling, format: { with: CASTLING }
  validates :en_passant, format: { with: EN_PASSANT }
  validates :half_move, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
  validates :move, numericality: { integer_only: true, greater_than_or_equal_to: 1 }
  validates :name, length: { maximum: MAX_NAME }, presence: true, uniqueness: true

  scope :by_name, -> { order(:name) }
  scope :by_opening, -> { order("openings.code") }
  scope :by_last_reviewed_desc, -> { order("last_reviewed DESC NULLS LAST") }
  scope :by_last_reviewed_asc, -> { order("last_reviewed ASC NULLS FIRST") }

  def self.search(params, path, opt={})
    matches = includes(:opening)
    matches = case params[:order]
      when "opening"       then matches.by_opening
      when "reviewed_asc"  then matches.by_last_reviewed_asc
      when "reviewed_desc" then matches.by_last_reviewed_desc
                           else matches.by_name
    end
    sql = nil
    matches = matches.where(sql) if sql = cross_constraint(params[:name], cols: %w{name})
    matches = matches.where(sql) if sql = cross_constraint(params[:notes], cols: %w{notes})
    paginate(matches, params, path, opt)
  end

  def reviewed_today=(bool)
    self.last_reviewed = Date.today if bool
  end

  def reviewed_today
    last_reviewed == Date.today
  end

  def last_reviewed_in_days
    return I18n.t("symbol.cross") if last_reviewed.blank?
    return I18n.t("symbol.tick")  if last_reviewed >= Date.today
    (Date.today - last_reviewed).to_i
  end

  def fen
    [pieces, active, castling, en_passant, half_move, move].join(" ")
  end

  def notes_html
    parts = [notes]
    parts.push "__ECO__: #{opening.code} #{opening.description}" if opening
    parts.push "__FEN__: #{fen}"
    to_html(parts.compact.join("\n\n"))
  end

  private

  def split_fen
    if pieces =~ /\A\s*([KQRBNPkqrbnp1-8\/]+)\s+(w|b)\s+(-|[KQkq]+)\s+(-|[a-h]\d)\s+(\d+)\s+(\d+)\s*\z/
      self.pieces = $1
      self.active = $2
      self.castling = $3
      self.en_passant = $4
      self.half_move = $5.to_i
      self.move = $6.to_i
    end
  end

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

  def proxy_symbols
    [:name, :notes].each do |a|
      if send(a).present?
        send "#{a}=", send(a).gsub(/(\+\/=|\$14)/, "⩲")
        send "#{a}=", send(a).gsub(/(=\/\+|\$15)/, "⩱")
        send "#{a}=", send(a).gsub(/(\+\/-|\$16)/, "±")
        send "#{a}=", send(a).gsub(/(-\/\+|\$17)/, "∓")
        send "#{a}=", send(a).gsub("$18", "+-")
        send "#{a}=", send(a).gsub("$19", "-+")
        send "#{a}=", send(a).gsub(/([KQBNR])([a-h1-8])?([a-h])([1-8])/) { "#{SYMBOL[$1]}#{$2}#{$3}#{$4}" }
        send "#{a}=", send(a).gsub(/([a-h])([a-h])?([18])\(([QBNR])\)/) { "#{$1}#{$2}#{$3}(#{SYMBOL[$4]})" }
        send "#{a}=", send(a).gsub(/\s+vs\.\s+/, " - ")
        send "#{a}=", send(a).gsub(/1\/2\s*-\s*1\/2/, "½-½")
        send "#{a}=", send(a).gsub(/([♔♕♖♗♘KQRBNa-h](?:[a-h1-8])?)x([a-h][1-8])/) { "#{$1}#{$2}" }
      end
    end
  end
end
