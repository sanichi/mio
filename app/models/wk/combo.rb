module Wk
  class Combo < ActiveRecord::Base
    MAX_COMBO = 128

    belongs_to :vocab, counter_cache: true

    before_validation :clean_up

    validates :ja, presence: true, length: { maximum: MAX_COMBO }
    validates :en, presence: true, length: { maximum: MAX_COMBO }

    private

    def clean_up
      ja&.squish!
      en&.squish!
    end
  end
end
