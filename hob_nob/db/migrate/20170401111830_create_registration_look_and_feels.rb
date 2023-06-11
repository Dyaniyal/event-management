class CreateRegistrationLookAndFeels < ActiveRecord::Migration
  def change
    create_table :registration_look_and_feels do |t|
      t.integer  "event_id"
      t.attachment "logo"
      t.string   "logo_alignment"
      t.string   "logo_back_color"
      t.attachment "banner_image"
      t.text   "header_formatter"
      t.string   "page_font_style"
      t.string   "header_font_size"
      t.string   "body_font_size"
      t.attachment "body_background_image"
      t.string   "body_background_color"
      t.string   "button_color"
      t.text   "footer_formatter"
      t.attachment   "footer_image"

      t.timestamps null: false
    end
  end
end
