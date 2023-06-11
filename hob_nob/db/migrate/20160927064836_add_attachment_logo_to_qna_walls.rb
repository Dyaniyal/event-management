class AddAttachmentLogoToQnaWalls < ActiveRecord::Migration
  def self.up
    change_table :qna_walls do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :qna_walls, :logo
  end
end
