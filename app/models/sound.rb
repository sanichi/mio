class Sound < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable
  include Vocabable

  BASE = "audio/boutwell"
  CATEGORIES = %w/kanji grammar vocab reading patterns/
  LEVELS = (1..5).to_a
  MAX_NAME = 100

  before_validation :normalize_attributes

  validates :category, inclusion: { in: CATEGORIES }
  validates :level, inclusion: { in: LEVELS }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :length, numericality: { integer_only: true, greater_than_or_equal_to: 0 }

  def self.search(matches, params, path, opt={})
    case params[:order]
    when "level"
      matches = matches.order(level: :desc)
    else
      matches = matches.order(:category, :name)
    end
    if CATEGORIES.include?(params[:category])
      matches = matches.where(category: params[:category])
    end
    if LEVELS.include?(params[:level].to_i)
      matches = matches.where(level: params[:level].to_i)
    end
    if sql = cross_constraint(params[:query], %w{name note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def update_level!(delta)
    if delta == 1 || delta == -1
      new_level = level + delta
      update_column(:level, new_level) if LEVELS.include?(new_level)
    end
  end

  def short_name
    name.sub(/\.\w+\z/, "")
  end

  def path
    "/#{BASE}/#{category}/#{name}"
  end

  def file
    Rails.root + "public" + BASE + category + name
  end

  def type
    "audio/#{name =~ /\.mp3\z/ ? 'mpeg' : 'mp4'}"
  end

  def note_html
    to_html(link_vocabs(note))
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
          tpath = Rails.root + "public" + BASE + c
          tpath.mkpath unless tpath.directory?
          tfile = tpath + sound.name
          FileUtils.copy(sfile, tfile)
        end
      end
    elsif Rails.env.production?
      CATEGORIES.each do |c|
        path = Rails.root + "public" + BASE + c
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
      self.note = nil
    else
      note.lstrip!
      note.rstrip!
      note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    end
  end
end
