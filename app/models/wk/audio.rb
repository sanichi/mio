module Wk
  class Audio < ActiveRecord::Base
    MAX_FILE = 64
    DEFAULT_BASE = "https://files.wanikani.com/"

    belongs_to :audible, polymorphic: true

    validates :file, presence: true, length: { maximum: MAX_FILE }, uniqueness: true

    def url
      "#{DEFAULT_BASE}#{file}"
    end
  end
end
