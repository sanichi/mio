module Pp
  class SyncLog < ApplicationRecord
    include Pageable

    self.table_name = 'pp_sync_logs'

    QUERY_TYPES = %w[stations_full stations_incremental prices_full prices_incremental].freeze

    validates :query_type, presence: true, inclusion: { in: QUERY_TYPES }
    validates :started_at, presence: true
    validates :records_scanned, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :records_created, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :records_updated, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :successful, -> { where(error_message: nil) }
    scope :failed, -> { where.not(error_message: nil) }
    scope :by_date, -> { order(started_at: :desc) }

    def self.search(params, path, opt = {})
      matches = by_date
      if params[:query_type].present? && QUERY_TYPES.include?(params[:query_type])
        matches = matches.where(query_type: params[:query_type])
      end
      paginate(matches, params, path, opt)
    end

    def success?
      error_message.nil?
    end

    def failed?
      !success?
    end

    # Find the most recent successful sync for stations (either full or incremental)
    def self.last_successful_stations_sync
      where(query_type: %w[stations_full stations_incremental])
        .successful
        .order(started_at: :desc)
        .first
    end

    # Find the most recent successful sync for prices (either full or incremental)
    def self.last_successful_prices_sync
      where(query_type: %w[prices_full prices_incremental])
        .successful
        .order(started_at: :desc)
        .first
    end
  end
end
