module Wk
  class Audio < ActiveRecord::Base
    MAX_FILE = 64
    DEFAULT_BASE = "https://cdn.wanikani.com/audios/"

    belongs_to :reading

    validates :file, presence: true, length: { maximum: MAX_FILE }, uniqueness: true

    def url
      "#{DEFAULT_BASE}#{file}"
    end
  end
end
