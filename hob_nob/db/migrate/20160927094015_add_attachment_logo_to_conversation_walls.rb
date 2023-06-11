class AddAttachmentLogoToConversationWalls < ActiveRecord::Migration
  def self.up
    change_table :conversation_walls do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :conversation_walls, :logo
  end
end
