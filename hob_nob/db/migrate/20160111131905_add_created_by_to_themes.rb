class AddCreatedByToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :created_by, :integer
  end
end
