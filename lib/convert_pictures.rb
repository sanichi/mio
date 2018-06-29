class ActiveStorageBlob < ActiveRecord::Base
end

class ActiveStorageAttachment < ActiveRecord::Base
  belongs_to :blob, class_name: 'ActiveStorageBlob'
  belongs_to :record, polymorphic: true
end

class ConvertToActiveStorage
  def self.init
    ActiveRecord::Base.connection.raw_connection.prepare("active_storage_blob_statement", <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    ActiveRecord::Base.connection.raw_connection.prepare("active_storage_attachment_statement", <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, LASTVAL(), $4)
    SQL
  end

  def self.make_active_storage_records(picture)
    blob_key = key(picture)
    filename = picture.image_file_name
    content_type = picture.image_content_type
    file_size = picture.image_file_size
    file_checksum = checksum(picture)
    created_at = picture.updated_at.iso8601
    blob_values = [blob_key, filename, content_type, file_size, file_checksum, created_at]
    ActiveRecord::Base.connection.raw_connection.exec_prepared("active_storage_blob_statement", blob_values)

    blob_name = "image2"
    record_type = "Picture"
    record_id = picture.id
    attachment_values = [blob_name, record_type, record_id, created_at]
    ActiveRecord::Base.connection.raw_connection.exec_prepared("active_storage_attachment_statement", attachment_values)

    puts "created #{picture.id}"
  end

  def self.copy_file(attachment)
    source = attachment.record.image.path

    dest_dir = File.join("public", "system", "pictures", "storage", attachment.blob.key.first(2), attachment.blob.key.first(4).last(2))
    dest = File.join(dest_dir, attachment.blob.key)

    puts "moving #{source} to #{dest}"
    FileUtils.mkdir_p(dest_dir)
    FileUtils.cp(source, dest)
  end

  def self.key(picture)
    SecureRandom.uuid
  end

  def self.checksum(picture)
    url = picture.image.path
    Digest::MD5.base64digest(File.read(url))
  end
end

begin
  raise "already done" if ActiveStorageAttachment.count > 0

  ConvertToActiveStorage.init

  Picture.find_each do |picture|
    ConvertToActiveStorage.make_active_storage_records(picture)
  end

  ActiveStorageAttachment.find_each do |attachment|
    ConvertToActiveStorage.copy_file(attachment)
  end
rescue => e
  puts "exception: #{e.message}\n#{e.backtrace.join("\n")}"
end
