module Wk
  class Audio < ActiveRecord::Base
    MAX_FILE = 64
    DEFAULT_BASE = "https://cdn.wanikani.com/audios/"

    has_one :vocab

    validates :file, presence: true, length: { maximum: MAX_FILE }, uniqueness: true
    validates :wk_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: true

    def url
      "#{DEFAULT_BASE}#{file}"
    end
  end
end
