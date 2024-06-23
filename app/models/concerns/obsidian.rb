module Obsidian
  extend ActiveSupport::Concern

  OBSIDIAN = "https://publish.obsidian.md/sanichi/"
  OBS_LEVEL = 9

  included do
    def obs_url() = OBSIDIAN + obs_name(url: true)
  end
end
