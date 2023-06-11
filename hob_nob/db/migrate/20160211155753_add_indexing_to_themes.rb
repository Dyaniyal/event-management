class AddIndexingToThemes < ActiveRecord::Migration
  def change
  	add_index :themes, [:name], :name => "index_name_on_themes"
  	#add_index :themes, [:updated_at], :name => "index_updated_at_on_themes"
  	add_index :themes, [:licensee_theme], :name => "index_licensee_theme_on_themes"
  	#add_index :themes, [:created_by], :name => "index_created_by_on_themes"
  end
end
