class RenameAttachmentName < ActiveRecord::Migration[5.2]
  def up
    execute("UPDATE active_storage_attachments SET name = 'image'")
  end

  def down
    execute("UPDATE active_storage_attachments SET name = 'image2'")
  end
end
