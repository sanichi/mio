class Picture < ApplicationRecord
  include Constrainable
  include Remarkable

  TYPES = "jpe?g|gif|png"
  SIZE = { tn: 100, xs: 300, sm: 600, md: 900, lg: 1200 }
  MAX_SIZE = (Rails.env.test?? 1 : 50).megabytes
  MAX_TITLE = 50

  has_and_belongs_to_many :people

  has_attached_file :image, styles: SIZE.each_with_object({}){ |(nm,sz),o| o[nm] = "#{sz}x#{sz}#{nm == :tn ? '#' : '>'}" }

  before_validation :normalize_attributes

  validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(#{TYPES})\z/, file_name: /\.(#{TYPES})\z/i }, size: { less_than: MAX_SIZE }

  default_scope { order(id: :desc) }

  def self.search(params)
    sql = nil
    matches = joins(:people)
    matches = matches.where(sql) if sql = cross_constraint(params[:name], table: :people)
    matches = matches.where(sql) if sql = cross_constraint(params[:description], cols: %w{description})
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
end
