class AddSocialIconsOnEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :need_social_icon, :string
  	add_column :edms, :social_icons, :string
  end
end
