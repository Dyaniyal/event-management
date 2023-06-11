class AddIdMicrositeFeatures < ActiveRecord::Migration
  def change
  	add_column :microsite_features, :microsite_id, :integer
  end
end
