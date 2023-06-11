class AddColumnNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :seo_name, :string
  end
end
