class AddAttachmentLogoToPollWalls < ActiveRecord::Migration
  def self.up
    change_table :poll_walls do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :poll_walls, :logo
  end
end
