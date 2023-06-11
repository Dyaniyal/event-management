class AddAttachmentLogoToQuizWalls < ActiveRecord::Migration
  def self.up
    change_table :quiz_walls do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :quiz_walls, :logo
  end
end
