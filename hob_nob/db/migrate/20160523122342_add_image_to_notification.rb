class AddImageToNotification < ActiveRecord::Migration
  def change
  	add_attachment :notifications, :image
  end
end
