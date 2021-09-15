class Sound < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  BASE = Rails.root + "public/audio/boutwell"
  CATEGORIES = %w/kanji grammar vocab reading patterns/
  LEVELS = (1..5).to_a
  MAX_NAME = 100

  before_validation :normalize_attributes

  validates :category, inclusion: { in: CATEGORIES }
  validates :level, inclusion: { in: LEVELS }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "name"
      order(:categorty, :name)
    when "level"
      order(level: :desc)
    else
      order(updated_at: :desc)
    end
    if sql = cross_constraint(params[:q], %w{name note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(note)
  end

  def self.init
    raise "instances already exist" unless self.count == 0
    if Rails.env.development?
      base = Pathname.new("/Users/mjo/Dropbox/Japanese")
      CATEGORIES.each do |c|
        dir = 'JLPT N5 ' + I18n.t("sound.categories.#{c}")
        spath = base + dir + "MP3s"
        raise "#{spath.to_s} doesn't exist" unless spath.directory?
        sfiles = spath.glob("*.mp3")
        raise "#{spath.to_s} doesn't have any mp3s" unless sfiles.size > 0
        sfiles.each do |sfile|
          sound = Sound.create!(name: sfile.basename, category: c)
          tpath = BASE + c
          tpath.mkpath unless tpath.directory?
          tfile = tpath + sound.name
          FileUtils.copy(sfile, tfile)
        end
      end
    elsif Rails.env.production?
      CATEGORIES.each do |c|
        path = BASE + c
        files = path.glob("*.mp3")
        raise "#{path.to_s} doesn't have any mp3s" unless files.size > 0
        files.each do |file|
          Sound.create!(name: file.basename, category: c)
        end
      end
    else
      raise "not in development or production"
    end
  rescue => e
    puts e.message
  end

  private

  def normalize_attributes
    name&.gsub!(/\s/, "")
    if note.blank?
      note = nil
    else
      note.lstrip!
      note.rstrip!
      note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    end
  end
end
