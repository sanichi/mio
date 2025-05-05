module Ks
  class Boot < ActiveRecord::Base
    include Pageable

    APPS = %w/reboot api bid chess hou mio rek sj smd sta step tmp wd/

    belongs_to :journal, class_name: "Ks::Journal", foreign_key: :ks_journal_id, counter_cache: true
  
    validates :server, inclusion: { in: SERVERS }
    validates :app, inclusion: { in: APPS }
    validates :happened_at, presence: true, uniqueness: { scope: [:server, :app], message: "the same time with the same server and app" }
  
    scope :descending, -> { order(happened_at: :desc, server: :desc, app: :desc) }
    scope :ascending,  -> { order(happened_at: :asc,  server: :desc, app: :desc) }

    def self.search(params, path, opt={})
      matches =
        case params[:order]
        when "happened"
          ascending
        else
          descending
        end
      matches = matches.where(server: params[:server]) if SERVERS.include?(params[:server])
      matches = matches.where(app: params[:app]) if APPS.include?(params[:app])
      paginate(matches, params, path, opt)
    end
  end
end
