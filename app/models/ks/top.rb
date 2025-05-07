module Ks
  class Top < ActiveRecord::Base
    belongs_to :journal, class_name: "Ks::Journal", foreign_key: :ks_journal_id, counter_cache: true
    has_many :procs, foreign_key: :ks_top_id, dependent: :destroy

    validates :server, inclusion: { in: SERVERS }
    validates :measured_at, presence: true, uniqueness: { scope: [:server], message: "the same time with the same server" }

    scope :descending, -> { order(measured_at: :desc, server: :desc) }
    scope :ascending,  -> { order(measured_at: :asc,  server: :desc) }
  end
end
