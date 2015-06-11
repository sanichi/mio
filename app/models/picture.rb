class Picture < ActiveRecord::Base
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
    matches = joins(:person).includes(:person)
    matches = matches.where("people.last_name ILIKE ?", "%#{params[:last_name]}%") if params[:last_name].present?
    if params[:first_names].present?
      pattern = "%#{params[:first_names]}%"
      matches = matches.where("first_names ILIKE ? OR known_as ILIKE ?", pattern, pattern)
    end
    matches = matches.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
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
