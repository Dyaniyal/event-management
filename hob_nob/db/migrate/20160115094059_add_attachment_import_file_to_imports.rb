class AddAttachmentImportFileToImports < ActiveRecord::Migration
  def self.up
    change_table :imports do |t|
      t.attachment :import_file
    end
  end

  def self.down
    remove_attachment :imports, :import_file
  end
end
