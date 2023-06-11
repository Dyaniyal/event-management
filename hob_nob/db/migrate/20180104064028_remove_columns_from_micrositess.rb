class RemoveColumnsFromMicrositess < ActiveRecord::Migration
  def change
  	remove_column :microsites, :header_background_color, :string
    remove_column :microsites, :footer_background_color, :string
    remove_column :microsites, :background_color, :string
    remove_column :microsites, :app_icon_file_name, :string
    remove_column :microsites, :app_icon_content_type, :string
    remove_column :microsites, :app_icon_file_size, :string
    remove_column :microsites, :app_icon_updated_at, :string
    remove_column :microsite_look_and_feels, :event_venue, :string
    remove_column :microsite_look_and_feels, :header_font_size, :string
    remove_column :microsite_look_and_feels, :button_font_color, :string
    remove_column :microsite_look_and_feels, :button_text, :string
    remove_column :microsite_look_and_feels, :microsite_form_header, :string
    remove_column :microsite_look_and_feels, :button_color, :string
    remove_column :microsite_look_and_feels, :footer_image_file_name, :string
    remove_column :microsite_look_and_feels, :footer_image_content_type, :string
    remove_column :microsite_look_and_feels, :footer_image_file_size, :string
    remove_column :microsite_look_and_feels, :footer_image_updated_at, :string
    remove_column :microsite_look_and_feels, :logo_alignment, :string
    remove_column :microsite_look_and_feels, :body_font_size, :string
    remove_column :microsite_look_and_feels, :page_font_style, :string
    remove_column :microsite_look_and_feels, :body_background_image_file_name, :string
    remove_column :microsite_look_and_feels, :body_background_image_content_type, :string
    remove_column :microsite_look_and_feels, :body_background_image_file_size, :string
    remove_column :microsite_look_and_feels, :body_background_image_updated_at, :string
    add_column :microsite_look_and_feels, :footer_background_color, :string
  end
end
