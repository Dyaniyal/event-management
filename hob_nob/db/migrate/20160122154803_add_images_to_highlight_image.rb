class AddImagesToHighlightImage < ActiveRecord::Migration
  def change
  	add_attachment :highligth_images, :highligth_image
  end
end
