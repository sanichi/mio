unless Rails.env.test?
  require "rack-mini-profiler"
  Rack::MiniProfiler.config.disable_caching = false if Rails.env.production?
  Rack::MiniProfiler.config.position = "right"
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
