 ActiveRecordDoctor.configure do
  # Global settings affect all detectors.
  global :ignore_tables, [
    # Ignore internal Rails-related tables.
    "ar_internal_metadata",
    "schema_migrations",
    "active_storage_blobs",
    "active_storage_attachments",
    "action_text_rich_texts",

    # Add project-specific tables here.
  ]

  # Detector-specific settings affect only one specific detector.
  detector :table_without_timestamps,
           ignore_tables: [
             /\Awk_/,
             "grammar_groups_grammars", # HABTM join table
             "people_pictures",         # HABTM join table
             "logins",                  # append-only log; created_at only
             "pp_sync_logs"             # append-only log; has started_at/duration
           ]

  detector :table_without_primary_key,
           ignore_tables: [
             "grammar_groups_grammars", # HABTM join table
             "people_pictures",         # HABTM join table
             "wk_kanjis_kanjis",        # HABTM join table
             "wk_kanjis_radicals"       # HABTM join table
           ]

  detector :unindexed_foreign_keys,
           ignore_columns: %w[
             partnerships.husband_id partnerships.wife_id
             people.father_id people.mother_id
             teams.fd_id teams.fwp_id
             wk_kanas.wk_id
           ] # tiny tables; wk_kanas.wk_id gets a unique index later

  detector :incorrect_length_validation,
           ignore_attributes: %w[
             Constellation.iau Misa.minutes
             Pp::Station.node_id Pp::Station.colour
             Star.alpha Star.delta Star.bayer
             Transaction.category
             Wk::Kanji.character Wk::Radical.character
             User.otp_secret Wk::VerbPair.tag
             Login.email Login.ip
           ] # lengths bounded by format/is: validators, generated values, or truncated before save

  detector :missing_presence_validation,
           ignore_models: %w[ActiveRecord::SessionStore::Session PersonPicture],
           ignore_attributes: %w[Match.home_team Match.away_team] # *_team_id already has numericality; FK covers the rest

  detector :short_primary_key_type,
           ignore_tables: %w[
             comments favourites flats logins masses
             partnerships people pictures returns users
           ] # int4 serial ids; tables are tiny, so overflow is not a concern
end
