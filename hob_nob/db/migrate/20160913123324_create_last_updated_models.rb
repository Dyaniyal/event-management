class CreateLastUpdatedModels < ActiveRecord::Migration
  def change
    create_table :last_updated_models do |t|
      t.string :model_name
      t.datetime :last_updated
    end
  end
end
