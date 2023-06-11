class AddAttachmentBackgroundImageToConversationWalls < ActiveRecord::Migration
  def self.up
    change_table :conversation_walls do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :conversation_walls, :background_image
  end
end
