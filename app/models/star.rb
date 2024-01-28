class Star < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable
  include StarLink

  belongs_to :constellation, counter_cache: true

  MAX_NAME = 40
  ALPHA = /\A([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])\z/
  DELTA = /\A(-)?([0-8][0-9])([0-5][0-9])([0-5][0-9])\z/
  BAYER = /\A([α-ωa-zA-z])([1-9]|10)?\z/
  GREEK = {alpha: "α", beta: "β", gamma: "γ", delta: "δ", epsilon: "ε", zeta: "ζ", eta: "η", theta: "θ", iota: "ι", kappa: "κ", lambda: "λ", mu: "μ", nu: "ν", xi: "ξ", omicron: "ο", pi: "π", rho: "ρ", sigma: "σ", tau: "τ", upsilon: "υ", phi: "φ", chi: "χ", psi: "ψ", omega: "ω"}

  before_validation :normalize_attributes

  validates :alpha, format: { with: ALPHA }
  validates :delta, format: { with: DELTA }
  validates :bayer, format: { with: BAYER }, uniqueness: { scope: :constellation_id }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { case_sensitive: false }
  validates :components, numericality: { integer_only: true, greater_than: 0, less_than: 10 }
  validates :distance, numericality: { integer_only: true, greater_than: 0 }
  validates :magnitude, numericality: { greater_than: -2.0, less_than: 7.0 }
  validates :mass, numericality: { greater_than: 0.01, less_than: 10000.0 }
  validates :radius, numericality: { greater_than: 0.01, less_than: 10000.0 }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "components"
      order(components: :desc)
    when "distance"
      order(:distance)
    when "magnitude"
      order(:magnitude)
    when "mass"
      order(mass: :desc)
    when "radius"
      order(radius: :desc)
    else
      order(:name)
    end
    matches = matches.includes(:constellation)
    if sql = cross_constraint(params[:q], %w{name note})
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:distance], :distance)
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:magnitude], :magnitude, digits: 2)
      matches = matches.where(sql)
    end
    if (cid = params[:constellation_id].to_i) > 0
      matches = matches.where(constellation_id: cid)
    end
    paginate(matches, params, path, opt)
  end

  def note_html = to_html(link_stars(note))

  def to_markdown(display, context)
    if context == self
      "**#{display}**"
    else
      "[#{display}](/stars/#{id})"
    end
  end

  private

  def normalize_attributes
    alpha&.gsub!(/\D+/, "")
    delta&.gsub!(/[^-0-9]+/, "")
    name&.squish!
    self.bayer = "" if bayer.nil?
    bayer.lstrip!
    bayer.rstrip!
    if bayer.match(/\A([a-z][a-z]+)/i) && (letter = GREEK[$1.downcase.to_sym])
      bayer.sub!(/\A[a-z][a-z]+/i, letter)
    end
    self.note = "" if note.nil?
    note.lstrip!
    note.rstrip!
    note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
