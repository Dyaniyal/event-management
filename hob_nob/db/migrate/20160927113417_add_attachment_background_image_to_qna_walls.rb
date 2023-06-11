class AddAttachmentBackgroundImageToQnaWalls < ActiveRecord::Migration
  def self.up
    change_table :qna_walls do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :qna_walls, :background_image
  end
end
