# Be sure to restart your server when you modify this file.
# Rails.application.config.session_store :cookie_store,
#   key: "_sni_mio_app_session",
#   expire_after: 2.weeks
Rails.application.config.session_store :active_record_store,
  key: "_sni_mio_app_ar_session",
  expire_after: 2.weeks
