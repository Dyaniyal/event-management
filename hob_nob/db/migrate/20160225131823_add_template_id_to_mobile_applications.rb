class AddTemplateIdToMobileApplications < ActiveRecord::Migration
  def change
    add_column :mobile_applications, :template_id, :integer
  end
end
