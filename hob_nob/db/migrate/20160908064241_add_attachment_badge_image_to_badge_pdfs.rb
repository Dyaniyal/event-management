class AddAttachmentBadgeImageToBadgePdfs < ActiveRecord::Migration
  def self.up
    change_table :badge_pdfs do |t|
      t.attachment :badge_image
    end
  end

  def self.down
    remove_attachment :badge_pdfs, :badge_image
  end
end
