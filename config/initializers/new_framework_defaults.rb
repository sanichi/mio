# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease upgrades (if you don't want/need new defaults).
#

# Require `belongs_to` associations by default. Previous versions had false.
# See https://blog.bigbinary.com/2016/02/15/rails-5-makes-belong-to-association-required-by-default.html
Rails.application.config.active_record.belongs_to_required_by_default = false

# See also the Rails config.load_defaults method (since 5.1). It does thigs like this:
# Rails.application.config.active_record.belongs_to_required_by_default = true
# Rails.application.config.action_controller.per_form_csrf_tokens = true
# Rails.application.config.action_controller.forgery_protection_origin_check = true
# Rails.application.config.assets.unknown_asset_fallback = false
# But it causes problems for me so is currently commented out in application.rb.
