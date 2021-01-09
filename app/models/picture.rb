class Picture < ApplicationRecord
  include Constrainable
  include Remarkable

  MAX_IMAGE = 20
  MAX_TITLE = 50
  SIZE = { tn: 100, xs: 300, sm: 600, md: 900, lg: 1200 }

  has_and_belongs_to_many :people

  before_validation :normalize_attributes

  validates :realm, numericality: { integer_only: true, greater_than_or_equal_to: Person::MIN_REALM, less_than_or_equal_to: Person::MAX_REALM }
  validates :image, length: { maximum: MAX_IMAGE }, format: { with: /\A[-A-Za-z_\d]+\.(jpg|png|gif)\z/ }, uniqueness: true
  validate :check_image
  validate :check_people_realm

  default_scope { order(id: :desc) }

  def self.search(params)
    sql = nil
    matches = joins(:people)
    matches = matches.where(sql) if sql = cross_constraint(params[:name], %w(last_name first_names known_as married_name), table: :people)
    matches = matches.where(sql) if sql = cross_constraint(params[:description], %w{description})
    matches = matches.where(realm: params[:realm].to_i)
    matches = matches.distinct
    matches
  end

  def description_html
    to_html(description)
  end

  def update_people(ids)
    return unless ids.respond_to?(:map)
    new_ids = ids.map(&:to_i).uniq.select{ |id| id > 0 }.sort
    old_ids = people.map(&:id).sort
    return if old_ids == new_ids
    self.people = new_ids.map{ |id| Person.find_by(id: id) }.compact
  end

  def path(thumbnail: true, abs: false)
    file = thumbnail ? image.sub('.', 't.') : image
    path = "people/#{file}"
    abs ? (Rails.root + "public" + path).to_s : "/#{path}"
  end

  def self.hidden_class(nm)
    case nm
    when :xs
      "d-block d-sm-none"
    when :sm
      "d-none d-sm-block d-md-none"
    when :md
      "d-none d-md-block d-lg-none"
    else
      "d-none d-lg-block"
    end
  end

  def self.number_of_cols(nm)
    case nm
    when :xs
      3
    when :sm
      4
    when :md
      6
    else
      9
    end
  end

  private

  def normalize_attributes
    self.description = nil unless description.present?
    self.title = calculate_title
  end

  def calculate_title
    if people.empty?
      I18n.t("picture.picture")
    else
      people.sort{ |a, b| a.known_as <=> b.known_as }.map{ |p| p.name(full: false) }.join(", ").truncate(MAX_TITLE);
    end
  end

  def check_people_realm
    errors.add(:realm, "not all people from this realm") unless people.all? { |p| p.realm == realm }
  end

  def check_image
    if image.present? && !Rails.env.test?
      errors.add(:image, "full image does not exist") unless File.file?(path(abs: true, thumbnail: false))
      errors.add(:image, "thumbnail does not exist") unless File.file?(path(abs: true, thumbnail: true))
    end
  end
end
