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
  detector :table_without_timestamps, ignore_tables: [/\Awk_/]
end
