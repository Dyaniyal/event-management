class AddAttachmentBackgroundImageToQuizWalls < ActiveRecord::Migration
  def self.up
    change_table :quiz_walls do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :quiz_walls, :background_image
  end
end
