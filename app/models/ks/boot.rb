module Ks
  class Boot < ActiveRecord::Base
    include Pageable
  
    validates :server, inclusion: { in: SERVERS }
    validates :app, inclusion: { in: APPS }
    validates :happened_at, presence: true, uniqueness: { scope: [:server, :app], message: "the same time with the same server and app" }
  
    scope :descending, -> { order(happened_at: :desc, server: :desc, app: :desc) }
    scope :ascending,  -> { order(happened_at: :asc,  server: :desc, app: :desc) }
  
    def self.search(params, path, opt={})
      matches = params[:order] == "asc" ? ascending : descending
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      matches = matches.where(app: params[:app]) if APPS.include?(params[:app])
      paginate(matches, params, path, opt)
    end
  end
end
