class AddImageSettingToMicrositeFeatures < ActiveRecord::Migration
  def change
  	add_column :microsite_features, :image_setting, :string
  	add_column :microsite_features, :faq_setting, :string
  end
end
