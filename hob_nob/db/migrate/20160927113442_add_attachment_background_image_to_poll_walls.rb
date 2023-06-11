class AddAttachmentBackgroundImageToPollWalls < ActiveRecord::Migration
  def self.up
    change_table :poll_walls do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :poll_walls, :background_image
  end
end
