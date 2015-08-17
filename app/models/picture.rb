class Picture < ActiveRecord::Base
  include Constrainable
  include Remarkable

  TYPES = "jpe?g|gif|png"
  SIZE = { tn: 100, xs: 300, sm: 600, md: 900, lg: 1200 }
  MAX_SIZE = (Rails.env.test?? 1 : 50).megabytes

  belongs_to :person
  has_attached_file :image, styles: SIZE.each_with_object({}){ |(nm,sz),o| o[nm] = "#{sz}x#{sz}#{nm == :tn ? '#' : '>'}" }

  before_validation :normalize_attributes

  validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(#{TYPES})\z/, file_name: /\.(#{TYPES})\z/i }, size: { less_than: MAX_SIZE }
  validates :person_id, numericality: { integer_only: true, greater_than: 0 }

  default_scope { order(id: :desc) }

  def self.search(params)
    sql = nil
    matches = joins(:person).includes(:person)
    matches = matches.where(sql) if (sql = cross_constraint(params[:name], table: :people))
    matches = matches.where(sql) if (sql = cross_constraint(params[:description], cols: ["description"]))
    matches
  end

  def description_html
    to_html(description)
  end

  private

  def normalize_attributes
    self.description = nil unless description.present?
  end
end
