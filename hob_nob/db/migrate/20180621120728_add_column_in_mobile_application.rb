class AddColumnInMobileApplication < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :agree_to_disclaimer_text, :string
  end
end
