class AddSequenceToMicrositeFeatures < ActiveRecord::Migration
  def change
    add_column :microsite_features, :sequence, :integer
  end
end
