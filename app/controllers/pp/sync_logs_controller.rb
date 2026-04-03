module Pp
  class SyncLogsController < ApplicationController
    def index
      @sync_logs = Pp::SyncLog.search(params, pp_sync_logs_path, per_page: 15)
    end
  end
end
