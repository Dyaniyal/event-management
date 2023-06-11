class AddMenuVisiblityToEventFeatures < ActiveRecord::Migration
  def change
    add_column :event_features, :menu_visibilty, :string
  end
end
