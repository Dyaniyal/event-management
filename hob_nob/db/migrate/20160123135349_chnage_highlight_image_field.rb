class ChnageHighlightImageField < ActiveRecord::Migration
  def change
  	rename_column :highligth_images, :highligth_image_file_name, :highlight_image_file_name
  	rename_column :highligth_images, :highligth_image_content_type, :highlight_image_content_type
  	rename_column :highligth_images, :highligth_image_file_size, :highlight_image_file_size
  	rename_column :highligth_images, :highligth_image_updated_at, :highlight_image_updated_at
  	rename_table :highligth_images, :highlight_images
  end
end
