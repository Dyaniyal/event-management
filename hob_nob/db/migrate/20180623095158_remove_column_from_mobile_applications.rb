class RemoveColumnFromMobileApplications < ActiveRecord::Migration
  def change
  	remove_column :mobile_applications, :agree_to_disclaimer_text, :string
  end
end
