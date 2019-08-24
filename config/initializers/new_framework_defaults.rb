# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease upgrades (if you don't want/need new defaults).
#

# Require `belongs_to` associations by default. Previous versions had false.
# See https://blog.bigbinary.com/2016/02/15/rails-5-makes-belong-to-association-required-by-default.html
Rails.application.config.active_record.belongs_to_required_by_default = false

# See also the Rails config.load_defaults method (since 5.0).
# This file takes precedence over anything in that method - i.e. this is
# my chance to maintain previous behaviour if I don't want new defaults.
