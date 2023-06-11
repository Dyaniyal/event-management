class CreateFonts < ActiveRecord::Migration

  def change
    create_table :fonts do |t|
      t.string :font_name
      t.references :client, index: true
      t.timestamps null: false
    end
    FileUtils.mkdir("#{Rails.root}/public/custom_fonts")
  end

end