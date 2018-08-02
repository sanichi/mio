class Picture < ApplicationRecord
  include Constrainable
  include Remarkable

  MAX_SIZE = (Rails.env.test?? 1 : 50).megabytes
  MAX_TITLE = 50
  SIZE = { tn: 100, xs: 300, sm: 600, md: 900, lg: 1200 }
  STYLE = SIZE.each_with_object({}) do |(nm,sz),v|
    if nm == :tn
      v[nm] = { thumbnail: "#{sz}x#{sz}^", gravity: "center", extent: "#{sz}x#{sz}" }
    else
      v[nm] = { resize: "#{sz}x#{sz}>" }
    end
  end
  TYPES = "jpe?g|gif|png"

  has_and_belongs_to_many :people

  before_destroy :cleanup_attachment

  has_one_attached :image, dependent: :purge

  before_validation :normalize_attributes

  validate :check_image_attachment

  default_scope { order(id: :desc) }

  def self.search(params)
    sql = nil
    matches = joins(:people).includes(:image_attachment).includes(:image_blob)
    matches = matches.where(sql) if sql = cross_constraint(params[:name], %w(last_name first_names known_as married_name), table: :people)
    matches = matches.where(sql) if sql = cross_constraint(params[:description], %w{description})
    matches = matches.where(people: { domain: params[:domain].to_i })
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

  def thumbnail_path
    Rails.application.routes.url_helpers.rails_representation_url(image.variant(STYLE[:tn]), only_path: true)
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

  def check_image_attachment
    if image.attached?
      errors.add(:image, "invalid content type (#{image.content_type})") unless image.content_type =~ /\Aimage\/(#{TYPES})\z/
      errors.add(:image, "invalid filename (#{image.filename})")         unless image.filename.to_s =~ /\.(#{TYPES})\z/i
      errors.add(:image, "too large an image size (#{image.byte_size})") unless image.byte_size < MAX_SIZE
    else
      errors.add(:image, "no image attached")
    end
  end

  def cleanup_attachment
    puts "cleanup attachment"
  end
end
