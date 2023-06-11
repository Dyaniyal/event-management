class AddColumnMobileToExhibitors < ActiveRecord::Migration
  def change
    add_column :exhibitors, :mobile, :string
  end
end
