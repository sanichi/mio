module Ks
  class Mem < ActiveRecord::Base
    include Pageable

    validates :server, inclusion: { in: SERVERS }
    validates :total, :used, numericality: { integer_only: true, greater_than: 0 }
    validates :free, :avail, :swap_used, :swap_free, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
    validates :measured_at, presence: true, uniqueness: { scope: [:server], message: "the same time with the same server" }

    scope :descending, -> { order(measured_at: :desc, server: :desc) }
    scope :ascending,  -> { order(measured_at: :asc,  server: :desc) }

    def self.search(params, path, opt={})
      matches = params[:order] == "asc" ? ascending : descending
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      paginate(matches, params, path, opt)
    end
  end
end

