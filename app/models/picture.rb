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

  # has_attached_file :image, styles: SIZE.each_with_object({}){ |(nm,sz),o| o[nm] = "#{sz}x#{sz}#{nm == :tn ? '#' : '>'}" }

  before_destroy :cleanup_attachment

  has_one_attached :image2, dependent: :purge

  before_validation :normalize_attributes

  validate :check_image_attachment

  # validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(#{TYPES})\z/, file_name: /\.(#{TYPES})\z/i }, size: { less_than: MAX_SIZE }

  default_scope { order(id: :desc) }

  def self.search(params)
    sql = nil
    matches = joins(:people)
    matches = matches.where(sql) if sql = cross_constraint(params[:name], %w(last_name first_names known_as married_name), table: :people)
    matches = matches.where(sql) if sql = cross_constraint(params[:description], %w{description})
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
    if image2.attached?
      errors.add(:image2, "invalid content type (#{image2.content_type})") unless image2.content_type =~ /\Aimage\/(#{TYPES})\z/
      errors.add(:image2, "invalid filename (#{image2.filename})")         unless image2.filename.to_s =~ /\.(#{TYPES})\z/i
      errors.add(:image2, "too large an image size (#{image2.byte_size})") unless image2.byte_size < MAX_SIZE
    else
      errors.add(:image2, "no image attached")
    end
  end

  def cleanup_attachment
    puts "cleanup attachment"
  end
end
